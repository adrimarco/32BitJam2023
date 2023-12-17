class_name AbilityEffect
extends Control


enum EffectType {	IncAtk, IncDef, IncSpd, 
					DecAtk, DecDef, DecSpd, 
					RecovHp, RecovMp, IncMpCost, DecMpCost,
					Stun, PushBack, PushFront,
					Purify, Lucky, StealHp}

enum DurationType {Immediate, Turns, Time, Tile}

var type 		:EffectType
var value		:float
var dur_type	:DurationType
var duration	:float
