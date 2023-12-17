class_name HasStunEffect extends ConditionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var p:Character = actor
	var hasEffect:bool = p.has_effects([AbilityEffect.EffectType.Stun])
	if hasEffect:
		return FAILURE
	return SUCCESS
