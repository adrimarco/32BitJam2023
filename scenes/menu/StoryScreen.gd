class_name StoryScreen
extends Control

signal story_finished

@onready var label 	:= $CanvasLayer/Label
@onready var timer	:= $CanvasLayer/Timer
@onready var anim_player	:= $CanvasLayer/AnimationPlayer

static var story_scene			:= preload("res://scenes/menu/StoryScreen.tscn")
static var texts :Array[String] = [	"Your allies fell defeated in the battle. Your adventure ends here. However, this is not the time to dwell on the defeat. You will continue training so that the next time you face an opportunity like this, you will not let it slip away.",
									"After defeating all the teams in the tournament and facing the ultimate challenge, you rise with the victory having vanquished the king. Now you join the royal squad of the kingdom and dedicate what remains of your lives to train and defend the realm from external threats. It is undoubtedly a hard work, but you also stop worrying about economic problems. Your life is now full of luxuries. Enjoy the reward, as you deserve it.",
									"In a distant kingdom, today the contenders tournament is celebrated. This event takes place once every ten years and gathers the most powerful warriors of the kingdom. The team that manages to overcome the rest of the opponents in the combats and surpasses the ultimate challenge, has the opportunity to join the royal squad of the kingdom and change their life forever. May luck be with you."]
static var TEXT_NORMAL_SPEED	= 20
static var TEXT_FAST_SPEED		= 60
static var SOUNDS_INTERVAL		= 0.15
static var FAST_SOUNDS_INTERVAL	= 0.07

var normal_speed		:bool 	= true
var characters_to_show	:float	= 0
var sound_time			:float	= 0

static func create_story_screen(node:Node, story_index:int, appear_smooth:bool = false) -> Signal:
	var story_screen := story_scene.instantiate()
	node.add_child(story_screen)
	if appear_smooth:
		story_screen.anim_player.play("start_story")
	
	if story_index >= 0 and story_index < texts.size():
		story_screen.label.text = texts[story_index]
	else:
		story_screen.label.text = ""
	
	return story_screen.story_finished

func exit_story_screen():
	anim_player.play("end_story")
	await anim_player.animation_finished
	
	story_finished.emit()
	queue_free()

func _ready():
	normal_speed = true
	label.visible_characters = 0

func _process(delta):
	if anim_player.is_playing():
		return
	
	if label.visible_ratio < 1.0:
		characters_to_show += delta * (TEXT_NORMAL_SPEED if normal_speed else TEXT_FAST_SPEED)
		sound_time += delta
		
		if floori(characters_to_show) > 0:
			var visible_characters = label.visible_characters + floori(characters_to_show)
			label.visible_characters = visible_characters
			characters_to_show -= floorf(characters_to_show)
		
		if sound_time >= (SOUNDS_INTERVAL if normal_speed else FAST_SOUNDS_INTERVAL):
			AudioPlayerInstance.play_ui_sound_by_index(AudioPlayerInstance.UI_TEXT_APPEAR)
			while sound_time >= (SOUNDS_INTERVAL if normal_speed else FAST_SOUNDS_INTERVAL):
				sound_time -= (SOUNDS_INTERVAL if normal_speed else FAST_SOUNDS_INTERVAL)
	else:
		if timer.is_stopped():
			if label.text.is_empty():
				exit_story_screen()
			else:
				timer.start()
	
	if label.visible_characters > 10 and Input.is_anything_pressed():
		if Input.is_action_just_pressed("action_accept") or Input.is_action_just_pressed("action_back"):
			# If text has finished, exit
			if label.visible_ratio >= 1.0:
				exit_story_screen()
			else:
				# Fasten text display
				if normal_speed:
					normal_speed = false
	
