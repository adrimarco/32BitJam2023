class_name AbilityEffectsContainer
extends Node

var EffectSprites:Array[Rect2] = [
	Rect2(0 , 0 , 32, 32), # Inc Attk
	Rect2(0 , 32, 32, 32), # Inc Def
	Rect2(64, 0 , 32, 32), # Inc Spd
	Rect2(32, 0 , 32, 32), # Dec Atk
	Rect2(32, 32, 32, 32), # Dec Def
	Rect2(96, 0 , 32, 32), # Dec Spd
	Rect2(0 , 0 , 0 , 0 ), # Recover hp
	Rect2(0 , 0 , 0 , 0 ), # Recover mp
	Rect2(0 , 64, 32, 32), # Inc MP cost
	Rect2(32, 64, 32, 32), # Dec MP cost
	Rect2(96, 32, 32, 32), # Stun
	Rect2(0 , 0 , 0 , 0 ), # push back
	Rect2(0 , 0 , 0 , 0 ), # push front
	Rect2(64, 32, 32, 32), # Luck
	Rect2(64, 64, 32, 32)  # Steal hp
]

var negative_effects := [	AbilityEffect.EffectType.DecAtk, AbilityEffect.EffectType.DecDef,
							AbilityEffect.EffectType.DecSpd, AbilityEffect.EffectType.IncMpCost,
							AbilityEffect.EffectType.Stun	]

func duplicate_effect(effect:AbilityEffect) -> AbilityEffect:
	var new_effect := _get_effect_with_value_and_duration(effect.value, effect.duration)
	
	new_effect.type 	= effect.type
	new_effect.dur_type = effect.dur_type
	
	return new_effect

func get_effect(type:AbilityEffect.EffectType, value:float, duration:float) -> AbilityEffect:
	if type == AbilityEffect.EffectType.IncAtk:
		return _attack_increase_effect(value, duration)
		
	elif type == AbilityEffect.EffectType.IncDef:
		return _defense_increase_effect(value, duration)
		
	elif type == AbilityEffect.EffectType.IncSpd:
		return _speed_increase_effect(value, duration)
		
	elif type == AbilityEffect.EffectType.DecAtk:
		return _attack_decrease_effect(value, duration)
		
	elif type == AbilityEffect.EffectType.DecDef:
		return _defense_decrease_effect(value, duration)
		
	elif type == AbilityEffect.EffectType.DecSpd:
		return _speed_decrease_effect(value, duration)
		
	elif type == AbilityEffect.EffectType.RecovHp:
		return _recover_health_effect(value, duration)
		
	elif type == AbilityEffect.EffectType.RecovMp:
		return _recover_energy_effect(value, duration)
		
	elif type == AbilityEffect.EffectType.IncMpCost:
		return _increase_energy_cost_effect(value, duration)
		
	elif type == AbilityEffect.EffectType.DecMpCost:
		return _decrease_energy_cost_effect(value, duration)
		
	elif type == AbilityEffect.EffectType.Stun:
		return _stunned_effect(value, duration)
		
	elif type == AbilityEffect.EffectType.PushBack:
		return _push_back_effect(value, duration)
		
	elif type == AbilityEffect.EffectType.PushFront:
		return _push_front_effect(value, duration)
	
	elif type == AbilityEffect.EffectType.Purify:
		return _purify_effect(value, duration)
		
	elif type == AbilityEffect.EffectType.Lucky:
		return _lucky_effect(value, duration)
		
	elif type == AbilityEffect.EffectType.StealHp:
		return _steal_health_effect(value, duration)
		
	return null

func _get_effect_with_value_and_duration(effect_value:float, effect_duration:float) -> AbilityEffect:
	var effect := AbilityEffect.new()
	
	effect.value 	= max(effect_value, 0)
	effect.duration = max(effect_duration, 1)
	
	return effect

func _attack_increase_effect(effect_value:float, effect_duration:float) -> AbilityEffect:
	var effect := _get_effect_with_value_and_duration(effect_value, effect_duration)
	
	effect.type 	= AbilityEffect.EffectType.IncAtk
	effect.dur_type = AbilityEffect.DurationType.Turns
	
	return effect

func _defense_increase_effect(effect_value:float, effect_duration:float) -> AbilityEffect:
	var effect := _get_effect_with_value_and_duration(effect_value, effect_duration)
	
	effect.type 	= AbilityEffect.EffectType.IncDef
	effect.dur_type = AbilityEffect.DurationType.Time
	
	return effect

func _speed_increase_effect(effect_value:float, effect_duration:float) -> AbilityEffect:
	var effect := _get_effect_with_value_and_duration(effect_value, effect_duration)
	
	effect.type 	= AbilityEffect.EffectType.IncSpd
	effect.dur_type = AbilityEffect.DurationType.Time
	
	return effect

func _attack_decrease_effect(effect_value:float, effect_duration:float) -> AbilityEffect:
	var effect := _get_effect_with_value_and_duration(effect_value, effect_duration)
	
	effect.type 	= AbilityEffect.EffectType.DecAtk
	effect.dur_type = AbilityEffect.DurationType.Turns
	
	return effect

func _defense_decrease_effect(effect_value:float, effect_duration:float) -> AbilityEffect:
	var effect := _get_effect_with_value_and_duration(effect_value, effect_duration)
	
	effect.type 	= AbilityEffect.EffectType.DecDef
	effect.dur_type = AbilityEffect.DurationType.Time
	
	return effect

func _speed_decrease_effect(effect_value:float, effect_duration:float) -> AbilityEffect:
	var effect := _get_effect_with_value_and_duration(effect_value, effect_duration)
	
	effect.type 	= AbilityEffect.EffectType.DecSpd
	effect.dur_type = AbilityEffect.DurationType.Time
	
	return effect

func _recover_health_effect(effect_value:float, effect_duration:float) -> AbilityEffect:
	var effect := _get_effect_with_value_and_duration(effect_value, effect_duration)
	
	effect.type 	= AbilityEffect.EffectType.RecovHp
	effect.dur_type = AbilityEffect.DurationType.Immediate
	
	return effect

func _recover_energy_effect(effect_value:float, effect_duration:float) -> AbilityEffect:
	var effect := _get_effect_with_value_and_duration(effect_value, effect_duration)
	
	effect.type 	= AbilityEffect.EffectType.RecovMp
	effect.dur_type = AbilityEffect.DurationType.Immediate
	
	return effect

func _increase_energy_cost_effect(effect_value:float, effect_duration:float) -> AbilityEffect:
	var effect := _get_effect_with_value_and_duration(effect_value, effect_duration)
	
	effect.type 	= AbilityEffect.EffectType.IncMpCost
	effect.dur_type = AbilityEffect.DurationType.Turns
	
	return effect

func _decrease_energy_cost_effect(effect_value:float, effect_duration:float) -> AbilityEffect:
	var effect := _get_effect_with_value_and_duration(effect_value, effect_duration)
	
	effect.type 	= AbilityEffect.EffectType.DecMpCost
	effect.dur_type = AbilityEffect.DurationType.Tile
	
	return effect

func _stunned_effect(effect_value:float, effect_duration:float) -> AbilityEffect:
	var effect := _get_effect_with_value_and_duration(effect_value, effect_duration)
	
	effect.type 	= AbilityEffect.EffectType.Stun
	effect.dur_type = AbilityEffect.DurationType.Turns
	
	return effect

func _push_back_effect(effect_value:float, effect_duration:float) -> AbilityEffect:
	var effect := _get_effect_with_value_and_duration(effect_value, effect_duration)
	
	effect.type 	= AbilityEffect.EffectType.PushBack
	effect.dur_type = AbilityEffect.DurationType.Immediate
	
	return effect

func _push_front_effect(effect_value:float, effect_duration:float) -> AbilityEffect:
	var effect := _get_effect_with_value_and_duration(effect_value, effect_duration)
	
	effect.type 	= AbilityEffect.EffectType.PushFront
	effect.dur_type = AbilityEffect.DurationType.Immediate
	
	return effect

func _purify_effect(effect_value:float, effect_duration:float) -> AbilityEffect:
	var effect := _get_effect_with_value_and_duration(effect_value, effect_duration)
	
	effect.type 	= AbilityEffect.EffectType.Purify
	effect.dur_type = AbilityEffect.DurationType.Immediate
	
	return effect

func _lucky_effect(effect_value:float, effect_duration:float) -> AbilityEffect:
	var effect := _get_effect_with_value_and_duration(effect_value, effect_duration)
	
	effect.type 	= AbilityEffect.EffectType.Lucky
	effect.dur_type = AbilityEffect.DurationType.Tile
	
	return effect

func _steal_health_effect(effect_value:float, effect_duration:float) -> AbilityEffect:
	var effect := _get_effect_with_value_and_duration(effect_value, effect_duration)
	
	effect.type 	= AbilityEffect.EffectType.StealHp
	effect.dur_type = AbilityEffect.DurationType.Tile
	
	return effect
