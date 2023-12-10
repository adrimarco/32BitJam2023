class_name Character
extends Node3D

signal attack_ready(Character)

# Constants
var ATTACK_READY_VALUE	:float	= 2.0
var SPRITE_VELOCITY		:float	= 100.0

# Class variables
@export var hp				:int	= 1
@export var mp				:int	= 1
@export var atk 			:int	= 1
@export var dfn 			:int	= 1
@export var spd 			:float	= 1
var attack_meter			:float	= 0.0
var preparing_attack		:bool	= false
var character_moving		:bool	= false
var grid_position			:Vector2i
var target_position			:Vector3 


func _init(h, m, a, d, s):
	hp 	= h
	mp 	= m
	atk = a
	dfn = d
	spd = s
	attack_meter 		= 0.0
	preparing_attack 	= false
	character_moving 	= false

func _ready():
	target_position = position

func _process(delta):
	update_attack_meter(delta)
	update_character_position(delta)
	
	return

func update_attack_meter(delta):
	if not preparing_attack:
		return
	
	# Charge attack
	attack_meter += delta * spd
	
	# Check if attack is ready to notify battlefield
	if attack_meter >= ATTACK_READY_VALUE:
		attack_ready.emit(self)
	
	return

func update_character_position(delta):
	if not character_moving:
		return
	
	# Get distance to target position
	var distance = position.distance_to(target_position)
	
	# Calculate movement
	var velocity = position.direction_to(target_position) * SPRITE_VELOCITY * delta
	velocity = max(velocity, target_position-position)
	
	# Update position
	position += velocity
	if position.distance_to(target_position) < 1.0:
		character_moving = false
	
	return

func stop_preparing_attack():
	preparing_attack = false

func prepare_attack():
	preparing_attack = true

func set_grid_position(new_pos:Vector2i):
	grid_position = new_pos

func move_to_world_position(new_pos:Vector3):
	target_position = new_pos
	character_moving = true

func reset_attack_meter():
	attack_meter -= ATTACK_READY_VALUE
