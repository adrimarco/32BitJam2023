class_name Ability
extends Node

enum TargetTypes {Area, Selection, Priority}
# Area: Affects all characters in range
# Selection: Affects the character/s selected by player inside the range
# Priority: Affects the character/s that satisfy a condition inside the range

var ability_name		:String
var description			:String
var dmg_multiplier		:float
var cost				:int
var range				:Callable
var target_enemy_team	:bool
var target_type			:TargetTypes
var priority_func		:Callable
#var effects_caster		:Array
#var effects_target		:Array
