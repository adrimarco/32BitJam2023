class_name AbilityEffect
extends Control


enum EffectType {	IncAtk, IncDef, IncSpd, 
					DecAtk, DecDef, DecSpd, 
					RecovHp, RecovMp, IncMpCost,
					Stun, PushBack, PushFront,
					Purify }

enum DurationType {Immediate, Turns, Time}

var type 		:EffectType
var value		:float
var dur_type	:DurationType
var duration	:float
