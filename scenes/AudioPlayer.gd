class_name AudioPlayer
extends Node

signal fade_music_finished

static var DB_FADE_PER_SECONDS	:= 30
static var UI_SOUNDS_DB			:= -6.0

static var BATTLE_MUSIC			:= 0
static var MENU_MUSIC			:= 1
static var BOSS_BATTLE_MUSIC	:= 2

static var UI_CHANGE_SELECT		:= 0
static var UI_MAKE_SELECT		:= 1
static var UI_UNDO_SELECT		:= 2
static var UI_TEXT_APPEAR		:= 3

@onready var music 	:= $Music
@onready var sfx	:= $SFX

var music_source 	:Array = [	preload("res://assets/music_sfx/Action 1 (Loop).ogg"),
								preload("res://assets/music_sfx/Action 2 (Loop).ogg"),
								preload("res://assets/music_sfx/Action 3 (Loop).ogg")]
var ui_source		:Array = [	preload("res://assets/music_sfx/Change selection.wav"),
								preload("res://assets/music_sfx/Make selection.wav"),
								preload("res://assets/music_sfx/Undo Selection.wav"),
								preload("res://assets/music_sfx/UIText Appear.wav")]
var music_db		:Array = [-9.0, -9.0, -9.0]
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

func play_ui_sound_by_index(index:int):
	if index < 0 or index >= ui_source.size():
		return
	
	var pitch := 1.0
	if index == UI_TEXT_APPEAR:
		pitch = randf_range(2, 2.4)
		
	play_sound_effet(ui_source[index], pitch, UI_SOUNDS_DB)

func play_sound_effet(source:Resource, pitch:float = 1.0, db:float = 0.0) -> AudioStreamPlayer:
	if not source:
		return
	
	var sfx_player := get_sfx_free_child()
	
	sfx_player.stream = source
	sfx_player.pitch_scale = pitch
	sfx_player.volume_db = db
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
