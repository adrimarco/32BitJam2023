extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	print("Moving")
	var battleManager:BattleManager = blackboard.get_value("battleManager")
	var a = blackboard.get_value("tiles").tiles[0]
	battleManager.do_action_movement(blackboard.get_value("tiles").tiles[0])
	return SUCCESS
