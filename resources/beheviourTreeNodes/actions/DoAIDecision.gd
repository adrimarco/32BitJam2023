extends ActionLeaf

func tick(_actor: Node, blackboard: Blackboard) -> int:
	# Get weights array and decide the ai turn
	var decisionWeightsMovement:Array = blackboard.get_value("decisionWeightsMovement")
	var decisionWeightsAttack:Array = blackboard.get_value("decisionWeightsAttack")
	return SUCCESS
