class_name Ability
extends Node

enum TargetTypes {Area, Selection, Priority}
# Area: Affects all characters in range
# Selection: Affects the character/s selected by player inside the range
# Priority: Affects the character/s that satisfy a condition inside the range

@export var ability_name		:String
@export var description			:String
@export var dmg_multiplier		:float
@export var cost				:int
@export var target_enemy_team	:bool
@export var target_type			:TargetTypes
@export var ability_range_name	:StringName
@export var priority_func_name	:StringName
@export_group("Caster effects")
@export var cast_effc_type		:Array[AbilityEffect.EffectType]
@export var cast_effc_value		:Array[float]
@export var cast_effc_dur		:Array[float]
@export_group("Target effects")
@export var target_effc_type	:Array[AbilityEffect.EffectType]
@export var target_effc_value	:Array[float]
@export var target_effc_dur		:Array[float]
var ability_range		:Callable
var priority_func		:Callable
var effects_caster		:Array[AbilityEffect]
var effects_target		:Array[AbilityEffect]

func _ready():
	ability_range = Callable(RangeFunctions, ability_range_name)
	priority_func = Callable(RangeFunctions, priority_func_name)
	
	# Create and save effects
	var effects_count :int = min(cast_effc_type.size(), cast_effc_value.size(), cast_effc_dur.size())
	for i in effects_count:
		effects_caster.append(EffectsContainer.get_effect(cast_effc_type[i], cast_effc_value[i], cast_effc_dur[i]))
	
	effects_count = min(target_effc_type.size(), target_effc_value.size(), target_effc_dur.size())
	for i in effects_count:
		effects_target.append(EffectsContainer.get_effect(target_effc_type[i], target_effc_value[i], target_effc_dur[i]))
