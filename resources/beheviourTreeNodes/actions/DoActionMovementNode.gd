extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	var battleManager:BattleManager = blackboard.get_value("battleManager")
	var a = blackboard.get_value("tiles").tiles[0]
	print("Moving to (" + str(a.x) + ", " + str(a.y) + ")")
	battleManager.do_action_movement(blackboard.get_value("tiles").tiles[0])
	blackboard.set_value("enemyMoved", true)
	return SUCCESS
