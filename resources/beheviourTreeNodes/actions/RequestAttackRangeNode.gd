extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	print("Request Attack")
	var battleManager:BattleManager = blackboard.get_value("battleManager")
	var tiles:RangeFunctions.TileCollection = battleManager.request_attack_range_for_enemy(actor)
	blackboard.set_value("tiles", tiles)
	if tiles.tiles.size() <= 0:
		return FAILURE
	return SUCCESS
