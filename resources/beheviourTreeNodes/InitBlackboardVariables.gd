extends ActionLeaf



func tick(actor: Node, blackboard: Blackboard) -> int:
	#blackboard.set_value("enemyMoved", false)
	blackboard.set_value("decisionWeightsMovement", [])
	blackboard.set_value("decisionWeightsAttack", [])
	return SUCCESS
