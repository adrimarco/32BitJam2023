class_name DamageCounter
extends Node3D

@onready var number_container	:= $Number3D
@onready var anim_player		:= $AnimationPlayer
var labels						:Array[Label3D]
var number						:= -1

func _ready():
	# Hide labels and save them
	for label in number_container.get_children():
		label.visible = false
		labels.append(label)

func display_number(n:int, alternative_animation:bool = false):
	number = clampi(n, 0, 999)
	
	var digit:int
	var digit_displayed:bool
	
	# Display different digits
	@warning_ignore("integer_division")
	digit = number/100
	if digit > 0:
		digit_displayed = true
		update_digit(0, str(digit))
	
	@warning_ignore("integer_division")
	digit = number/10 % 10
	if digit > 0 or digit_displayed:
		digit_displayed = true
		update_digit(1, str(digit))
	
	digit = number % 10
	update_digit(2, str(digit))
	
	# Play animation
	anim_player.play("critic_appear" if alternative_animation else "number_appear")

func update_digit(label_index:int, value:String):
	if labels.size() > label_index:
		labels[label_index].text = value
		labels[label_index].visible = true

func _on_animation_player_animation_finished(_anim_name):
	queue_free()
