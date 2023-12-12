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
@export var ability_range		:Callable
@export var target_enemy_team	:bool
@export var target_type			:TargetTypes
@export var priority_func		:Callable
#var effects_caster		:Array
#var effects_target		:Array
