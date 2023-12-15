class_name Character
extends Node3D

signal attack_ready(ch:Character)
signal health_changed(new_health:int)
signal energy_changed(new_energy:int)
signal attack_animation_finished(ch:Character)
signal tile_movement_finished(ch:Character)

# Constants
static var ATTACK_READY_VALUE	:float	= 30.0
static var SPRITE_VELOCITY		:float	= 1.0
static var ATTACK_INC_PER_TILE	:float	= 0.15
static var DEFENSE_DEC_PER_TILE	:float	= 0.1
static var CRITICAL_MULTIPLIER	:float	= 0.5
static var MP_RECOVER_INTERVAL	:float	= 0.3
static var MP_RECOVER_AT_REST	:int	= 20

# Scenes
var damage_counter_scene 		:= preload("res://scenes/battle/DamageCounter.tscn")

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
@export var abilitiesScene	:Array[PackedScene] = []
var attack_meter			:float	= 0.0
var mp_timer				:float	= 0.0
var preparing_attack		:bool	= false
var character_moving		:bool	= false
var grid_position			:Vector2i
var target_position			:Vector3 
var basic_attack			:Ability
var abilities				:Array[Ability]
var hp						:int	= 1:
	set(new_value):
		hp = new_value
		health_changed.emit(hp)
var mp						:int	= 1:
	set(new_value):
		mp = new_value
		energy_changed.emit(mp)


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
	update_energy(delta)
	
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
		tile_movement_finished.emit(self)
	
	return

func update_energy(delta):
	if not preparing_attack or mp >= maxmp:
		return
	
	mp_timer += delta
	
	if mp_timer >= MP_RECOVER_INTERVAL:
		var energy_recovered := floori(mp_timer/MP_RECOVER_INTERVAL)
		mp = min(mp + energy_recovered, maxmp)
		mp_timer -= energy_recovered * MP_RECOVER_INTERVAL

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

func reset_idle_animation():
	if sprite.animation == "attack":
		attack_animation_finished.emit(self)
	
	if sprite.animation != "idle":
		sprite.play("idle")

func play_attack_animation():
	sprite.play("attack")

func initializeCharacterAbilities():
	# Instantiate basic ability
	if basicAttackScene:
		basic_attack = basicAttackScene.instantiate()
		add_child(basic_attack)
	
	# Instantiate special abilities
	clearAbilitiesArray()
	if abilitiesScene.size() == 0:
		return
	for ab in abilitiesScene:
		if ab:
			abilities.append(ab.instantiate())
			add_child(abilities.back())

func clearAbilitiesArray():
	for ab in abilities:
		if ab:
			ab.queue_free()
	abilities.clear()

func recover_extra_energy():
	mp = min(mp + MP_RECOVER_AT_REST, maxmp)
	play_attack_animation()
	
func damaged(attacker:Character, abl:Ability):
	if abl.dmg_multiplier <= 0.001:
		return
	
	# Calculate damage from ability and attacker's attack power
	var attack_power :float = attacker.atk * abl.dmg_multiplier
	# Apply tile attack increment and critical bonus (randomly)
	attack_power += attacker.atk * (ATTACK_INC_PER_TILE * attacker.grid_position.x)
	var critic_damage := add_critical_damage(attack_power)
	attack_power += critic_damage
	
	# Calculate target defense
	var defense_power :float = dfn * (1 - DEFENSE_DEC_PER_TILE * grid_position.x)
	
	var damage :int = maxi(1, floori(attack_power - defense_power))
	hp -= damage
	
	# Display damage
	var counter := damage_counter_scene.instantiate()
	counter.position.y = 1
	add_child(counter)
	counter.display_number(damage, critic_damage > 0.001)
	
	print("Deal " + str(damage) + " damage -> Health: " + str(hp) + "/" + str(maxhp))

func add_critical_damage(damage:float) -> float:
	var random_value := randi() % 1000
	
	if random_value <= 50:
		return damage * CRITICAL_MULTIPLIER
	
	return 0.0
