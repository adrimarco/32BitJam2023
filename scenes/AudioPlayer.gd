class_name AudioPlayer
extends Node

signal fade_music_finished

static var DB_FADE_PER_SECONDS	:= 30
static var BATTLE_MUSIC			:= 0
static var MENU_MUSIC			:= 1

@onready var music 	:= $Music
@onready var sfx	:= $SFX

var music_source 	:Array = [	preload("res://assets/music_sfx/Action 1 (Loop).ogg"),
								preload("res://assets/music_sfx/Action 2 (Loop).ogg")]
var music_db		:Array = [-6.0, -6.0]
var current_music	:int
var current_db		:float
var fading_music	:bool

func _ready():
	current_music 	= -1
	current_db 		= 0.0

func _process(delta):
	if fading_music:
		fade_music(delta)

func play_music_by_index(index:int, smooth_transition:bool = true):
	if index < 0 or index > music_source.size() or index == current_music:
		return
	
	if index < music_db.size():
		current_db = music_db[index]
	else:
		current_db = 0.0
	
	if smooth_transition and current_music != -1:
		fading_music = true
		await fade_music_finished
		
	current_music = index
	music.stream = music_source[index]
	set_music_bus_db(current_db)
	music.play()

func resume_music():
	if current_music != -1:
		music.playing = true
		fading_music = false
		set_music_bus_db(current_db)

func pause_music(smooth_transition:bool = false):
	if smooth_transition:
		fading_music = true
		await fade_music_finished
		
	music.playing = false
	fading_music = false

func stop_music(smooth_transition:bool = false):
	if smooth_transition:
		fading_music = true
		await fade_music_finished
	
	music.stop()
	current_music = -1
	fading_music = false

func fade_music(delta:float):
	var db := AudioServer.get_bus_volume_db(1)
	if db <= -80.0:
		fading_music = false
		fade_music_finished.emit()
	else:
		AudioServer.set_bus_volume_db(1, db - delta * DB_FADE_PER_SECONDS)
	

func set_music_bus_db(db:float):
	AudioServer.set_bus_volume_db(1, db)

func play_sound_effet(source:Resource) -> AudioStreamPlayer:
	if not source:
		return
	
	var sfx_player := get_sfx_free_child()
	
	sfx_player.stream = source
	sfx_player.play()
	
	return sfx_player

func get_sfx_free_child() -> AudioStreamPlayer:
	var player = null
	
	for child in sfx.get_children():
		if not child.playing:
			player = child
			break
		
	if player == null:
		player = AudioStreamPlayer.new()
		sfx.add_child(player)
	
	return player


func _on_music_finished():
	current_music = -1
