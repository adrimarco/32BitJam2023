extends ActionLeaf
# Do action movement node

func tick(actor: Node, blackboard: Blackboard) -> int:
	var battleManager:BattleManager = blackboard.get_value("battleManager")
	var moveTiles = blackboard.get_value("tilesMovement").tiles
	var decisionWeightsMovement:Array = blackboard.get_value("decisionWeightsMovement")
	battleManager.do_action_movement(decisionWeightsMovement[0])
	blackboard.set_value("enemyMoved", true)
	
	return SUCCESS
