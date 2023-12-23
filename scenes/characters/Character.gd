class_name Character
extends Node3D

signal attack_ready(ch:Character)
signal health_changed(new_health:int)
signal energy_changed(new_energy:int)
signal attack_animation_finished(ch:Character)
signal tile_movement_finished(ch:Character)
signal character_dead(ch:Character)

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
@onready var anim_player= $AnimationPlayer

# Class variables
@export var maxhp			:int	= 1
@export var maxmp			:int	= 1
@export var atk 			:int	= 1
@export var dfn 			:int	= 1
@export var spd 			:float	= 1
@export var character_name	:String	= "Dummy"
@export var basicAttackScene:PackedScene = preload("res://scenes/abilities/SlashAttack.tscn")
@export var abilitiesScene	:Array[PackedScene] = []
@export_range (0, 100) var aggressivity:int = 0
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
var current_effects			:Array[AbilityEffect]
@onready var effectListNode 		= $EffectList
@onready var effectListSpriteBase 	= $EffectList/SpriteBase
@onready var effectListBG 			= $EffectList/SpriteBG
var effect_icons:Array[Sprite3D] 	= [] 


func _ready():
	# Init character values
	hp					= maxhp
	mp 					= maxmp
	attack_meter 		= 0.0
	preparing_attack 	= false
	character_moving 	= false
	current_effects.clear()
	
	initializeCharacterAbilities()
	
	target_position = global_position
	grid_position = Vector2i(-1, -1)
	update_character_y_offset()

func _process(delta):
	update_attack_meter(delta)
	update_character_position(delta)
	update_energy(delta)
	update_effects(delta)
	
	return

func update_attack_meter(delta):
	if not preparing_attack:
		return
	
	# Charge attack
	attack_meter += delta * spd * get_speed_multiplier_by_effects(self)
	
	# Check if attack is ready to notify battlefield
	if attack_meter >= ATTACK_READY_VALUE:
		attack_ready.emit(self)
	
	return

func update_effects(delta):
	if not preparing_attack:
		return
	update_effects_duration(AbilityEffect.DurationType.Time, delta)

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
	if hp > 0:
		preparing_attack = true

func set_grid_position(new_pos:Vector2i):
	grid_position = new_pos

func get_ability_cost_from_character(ability:Ability) -> int:
	var cost := ability.cost
	var multiplier := 1.0
	
	for effect in current_effects:
		if effect.type == AbilityEffect.EffectType.IncMpCost:
			multiplier *= 1 + (effect.value / 100.0)
		elif effect.type == AbilityEffect.EffectType.DecMpCost:
			multiplier *= 1 - effect.value / 100.0
		
	return max(cost * multiplier, 0)

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

func play_rest_animation():
	anim_player.play("rest")

func _on_animation_player_animation_finished(anim_name):
	attack_animation_finished.emit(self)

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

func recover_energy(mp_recovered:int = MP_RECOVER_AT_REST):
	mp = min(mp + mp_recovered, maxmp)

func recover_health(hp_recovered:int):
	hp = min(hp + hp_recovered, maxhp)

func damaged(attacker:Character, abl:Ability):
	if abl.dmg_multiplier <= 0.001:
		return
	
	# Calculate damage from ability, attacker's attack power and effect
	var attack_power :float = attacker.atk * abl.dmg_multiplier * get_damage_multiplier_by_effects(attacker)
	# Apply tile attack increment and critical bonus (randomly)
	attack_power += attacker.atk * (ATTACK_INC_PER_TILE * attacker.grid_position.x)
	var critic_damage := add_critical_damage(attacker, attack_power)
	attack_power += critic_damage
	
	# Calculate target defense
	var defense_power :float = dfn * (1 - DEFENSE_DEC_PER_TILE * grid_position.x) * get_defense_multiplier_by_effects(self)
	
	var damage :int = maxi(1, floori(attack_power - defense_power))
	hp -= damage
	
	# If attacker has steal health effect, they recover hp
	if attacker.has_effects([AbilityEffect.EffectType.StealHp]):
		var steal_hp_effect := attacker.get_effect(AbilityEffect.EffectType.StealHp)
		@warning_ignore("narrowing_conversion")
		attacker.recover_health(damage * (steal_hp_effect.value/100.0))
	
	# Display damage
	var counter := damage_counter_scene.instantiate()
	counter.position.y = 1
	add_child(counter)
	counter.display_number(damage, critic_damage > 0.001)
	
	print("Deal " + str(damage) + " damage -> Health: " + str(hp) + "/" + str(maxhp))
	# If character dies, notify
	if hp <= 0:
		await get_tree().create_timer(1.0).timeout
		character_dead.emit(self)

func get_damage_multiplier_by_effects(ch:Character) -> float:
	var multiplier := 1.0
	
	for effect in ch.current_effects:
		if effect.type == AbilityEffect.EffectType.IncAtk:
			print("Damage increased")
			var increment = effect.value / 100.0
			multiplier += increment
		elif effect.type == AbilityEffect.EffectType.DecAtk:
			print("Damage decreased")
			var decrement = effect.value / 100.0
			multiplier -= decrement
	
	return multiplier

func get_defense_multiplier_by_effects(ch:Character) -> float:
	var multiplier := 1.0
	
	for effect in ch.current_effects:
		if effect.type == AbilityEffect.EffectType.IncDef:
			print("Defense increased")
			var increment = effect.value / 100.0
			multiplier += increment
		elif effect.type == AbilityEffect.EffectType.DecDef:
			print("Defense decreased")
			var decrement = effect.value / 100.0
			multiplier -= decrement
	
	return multiplier

func get_speed_multiplier_by_effects(ch:Character) -> float:
	var multiplier := 1.0
	
	for effect in ch.current_effects:
		if effect.type == AbilityEffect.EffectType.IncSpd:
			var increment = effect.value / 100.0
			multiplier += increment
		elif effect.type == AbilityEffect.EffectType.DecSpd:
			var decrement = effect.value / 100.0
			multiplier -= decrement
	
	return multiplier

func add_critical_damage(attacker:Character, damage:float) -> float:
	var random_value := randi() % 1000
	
	if random_value <= get_critical_chance(attacker):
		return damage * CRITICAL_MULTIPLIER
	
	return 0.0

func get_critical_chance(attacker:Character) -> int:
	var limit_value := 50
	
	for effect in attacker.current_effects:
		if effect.type == AbilityEffect.EffectType.Lucky:
			limit_value = max(limit_value, 1000 * (effect.value/100.0))
		
	return limit_value

func has_effects(effect_searched:Array[AbilityEffect.EffectType]) -> bool:
	for effect in current_effects:
		if effect.type in effect_searched:
			return true
		
	return false

func get_effect(effect_searched:AbilityEffect.EffectType) -> AbilityEffect:
	for effect in current_effects:
		if effect.type == effect_searched:
			return effect
		
	return null

func add_special_effect(new_effect:AbilityEffect):
	for e in current_effects:
		if e.type == new_effect.type:
			if new_effect.duration > e.duration or new_effect.value > e.value:
				e.duration 	= new_effect.duration
				e.value		= new_effect.value
			return
	
	current_effects.append(EffectsContainer.duplicate_effect(new_effect))
	show_effects_icons()

func remove_negative_effects():
	var i := 0
	while i < current_effects.size():
		if current_effects[i].type in EffectsContainer.negative_effects:
			current_effects.remove_at(i)
		else:
			i += 1
		
	show_effects_icons()

func remove_tile_effects():
	var i := 0
	while i < current_effects.size():
		if current_effects[i].type in BattlefieldGrid.LUCKY_TILE_EFFECTS:
			current_effects.remove_at(i)
			show_effects_icons()
		else:
			i += 1
	

func update_effects_duration(duration_type:AbilityEffect.DurationType, value:float):
	# Prevent value from being negative
	value = max(value, 0.0)
	
	var i := 0
	while i < current_effects.size():
		# Update effects that match given duration type
		if current_effects[i].dur_type == duration_type:
			current_effects[i].duration -= value
			if current_effects[i].duration <= 0.0:
				current_effects.remove_at(i)
				show_effects_icons()
				continue
			
		i += 1
	
func show_effects_icons():
	if current_effects.size() > 0:
		effectListBG.visible = true
	else:
		effectListBG.visible = false
	
	for effIcon in effect_icons:
		effIcon.queue_free()
	effect_icons.clear()
	
	for eff in current_effects:
		var rectSprite:Rect2 = EffectsContainer.EffectSprites[eff.type]
		
		if rectSprite.size.x == 0:
			continue
			
		var new_sprite = effectListSpriteBase.duplicate()
		new_sprite.visible = true
		var texture_atlas = AtlasTexture.new()
		texture_atlas.atlas  = preload("res://assets/characters/effects.png")
		texture_atlas.region = rectSprite
		new_sprite.texture = texture_atlas
		effect_icons.append(new_sprite)
		
	# Increase background size to fit all icons
	effectListBG.scale.x = effect_icons.size() + 0.4
	
	# Calculate first icon position
	var x_pos:float = (effect_icons.size()/2) * -0.32
	if effect_icons.size() % 2 != 0:
		x_pos -= 0.16
	
	for icon in effect_icons:
		# Add sprite to the scene
		icon.position += Vector3(x_pos, 0, 0)
		effectListNode.add_child(icon)
		
		x_pos += 0.32
	
