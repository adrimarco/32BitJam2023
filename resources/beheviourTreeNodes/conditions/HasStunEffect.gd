class_name HasStunEffect extends ConditionLeaf

func tick(actor: Node, blackboard: Blackboard) -> int:
	var p:Character = actor
	var hasEffect:bool = p.has_effects([AbilityEffect.EffectType.Stun])
	if hasEffect:
		blackboard.set_value("tilesMovement", null)
	return SUCCESS
