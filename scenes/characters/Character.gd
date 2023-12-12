class_name Character
extends Node3D

signal attack_ready(ch:Character)

# Constants
static var ATTACK_READY_VALUE	:float	= 10.0
static var SPRITE_VELOCITY		:float	= 1.0

# Nodes
@onready var sprite		= $Sprite

# Class variables
@export var maxhp			:int	= 1
@export var maxmp			:int	= 1
@export var atk 			:int	= 1
@export var dfn 			:int	= 1
@export var spd 			:float	= 1
@export var character_name	:String	= "Dummy"
@export var basicAttackScene:PackedScene = preload("res://scenes/abilities/SlashAttack.tscn")
@export var abilitiesScene:Array[PackedScene] = []
var hp				:int	= 1
var mp				:int	= 1
var attack_meter			:float	= 0.0
var preparing_attack		:bool	= false
var character_moving		:bool	= false
var grid_position			:Vector2i
var target_position			:Vector3 
var basicAttack:Ability
var abilities:Array[Ability]


func _ready():
	# Init character values
	hp					= maxhp
	mp 					= maxmp
	attack_meter 		= 0.0
	preparing_attack 	= false
	character_moving 	= false
	
	initializeCharacterAbilities()
	
	target_position = global_position
	grid_position = Vector2i(-1, -1)
	update_character_y_offset()

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
	
	var dist = global_position.distance_to(target_position)
	
	# Calculate movement
	var velocity:Vector3 = global_position.direction_to(target_position) * SPRITE_VELOCITY * delta
	
	if velocity.length() > dist:
		global_position = target_position
	else:
		global_position += velocity
	
	if global_position.distance_to(target_position) < 0.01:
		character_moving = false
	
	return

func stop_preparing_attack():
	preparing_attack = false

func prepare_attack():
	preparing_attack = true

func set_grid_position(new_pos:Vector2i):
	grid_position = new_pos

func move_to_world_position(new_pos:Vector3, teleport:bool = false):
	target_position = new_pos
	if teleport:
		global_position = new_pos
	else:
		character_moving = true
	

func reset_attack_meter():
	attack_meter -= ATTACK_READY_VALUE

func update_character_y_offset():
	# Offset equals half sprite height
	sprite.offset.y = sprite.get_item_rect().size.y/2
	
func initializeCharacterAbilities():
	# Instantiate basic ability
	if basicAttackScene:
		basicAttack = basicAttackScene.instantiate()
		
	# Instantiate special abilities
	clearAbilitiesArray()
	if abilitiesScene.size() == 0:
		return
	for ab in abilitiesScene:
		if ab:
			abilities.append(ab.instantiate())

func clearAbilitiesArray():
	for ab in abilities:
		if ab:
			ab.queue_free()
	abilities.clear()
