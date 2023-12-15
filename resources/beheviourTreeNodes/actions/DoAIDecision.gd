extends ActionLeaf

func tick(_actor: Node, blackboard: Blackboard) -> int:
	# Get weights array and decide the ai turn
	var battleManager:BattleManager = blackboard.get_value("battleManager")
	var decisionWeightsMovement:Array = blackboard.get_value("decisionWeightsMovement")
	var decisionWeightsAttack:Array = blackboard.get_value("decisionWeightsAttack")
	var att = blackboard.get_value("attack")
	if !att:
		return FAILURE
	battleManager.do_action_movement(decisionWeightsMovement[0])
	battleManager.do_action_attack(att[2], att[0])
	blackboard.set_value("enemyMoved", true)
	return SUCCESS
