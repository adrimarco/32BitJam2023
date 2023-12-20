class_name CharSelectorOption
extends Control

@onready var background			:= $Background
@onready var label				:= $Background/CharacterName
@onready var anim_player		:= $AnimationPlayer

var option_value				:= -1
var selected					:bool

func _ready():
	set_selected(false)

func set_option_value(new_value:int):
	option_value = new_value

func set_character_name(n:String):
	if label:
		label.text = n

func set_selected(is_selected:bool):
	selected = is_selected
	set_style()

func set_focus():
	anim_player.play("focus")
	

func set_background_x(x:int):
	background.position.x = x

func set_style():
	if selected:
		background.size.x = 180
		background.modulate = Color(1.0, 1.0, 0.0)
	else:
		background.size.x = 160
		background.modulate = Color(1.0, 1.0, 1.0)
	
	anim_player.stop()
	set_background_x(0)
