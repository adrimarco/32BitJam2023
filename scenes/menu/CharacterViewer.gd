class_name CharacterViewer
extends Control

@onready var sprite				:= $Border/CharacterData/Sprite
@onready var name_value			:= $Border/CharacterData/CharacterName
@onready var stats_values		:= $Border/CharacterData/StatsValues
@onready var abilities_values	:= $Border/CharacterData/AbilitiesValues
@onready var container			:= $Border/CharacterData

func _ready():
	container.hide()

func set_character_to_display(ch:Character):
	if not ch:
		return
	
	update_sprite(ch)
	update_character_name(ch)
	update_stats_labels(ch)
	update_abilities_list(ch)
	
	container.show()

func hide_stats():
	container.hide()

func update_sprite(ch:Character):
	if not ch or not ch.sprite:
		return
	
	sprite.sprite_frames = ch.sprite.sprite_frames
	if sprite.sprite_frames.has_animation("idle"):
		sprite.play("idle")
	else:
		sprite.stop()
	sprite.offset.y = -sprite.sprite_frames.get_frame_texture(sprite.animation, 0).get_height()/2

func update_character_name(ch:Character):
	if not ch:
		return
	
	name_value.text = ch.character_name

func update_stats_labels(ch:Character):
	if not ch:
		return
	
	var new_text :String 	= str(ch.maxhp) + "\n\n"
	new_text				+= str(ch.maxmp) + "\n\n"
	new_text				+= str(ch.atk) + "\n\n"
	new_text				+= str(ch.dfn) + "\n\n"
	new_text				+= str(ch.spd)
	stats_values.text = new_text

func update_abilities_list(ch:Character):
	if not ch:
		return
	
	var new_text :String = ""
	
	for ability in ch.abilities:
		new_text += ability.ability_name + "\n\n"
	
	abilities_values.text = new_text
