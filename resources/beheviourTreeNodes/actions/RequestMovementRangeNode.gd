extends ActionLeaf
# Request movement node


func tick(actor: Node, blackboard: Blackboard) -> int:
	print("Request Movement")
	var battleManager:BattleManager = blackboard.get_value("battleManager")
	var tiles:RangeFunctions.TileCollection = battleManager.request_movement_range_for_enemy(actor)
	
	if tiles.tiles.size() <= 0:
		return FAILURE
	
	blackboard.set_value("tilesMovement", tiles)
			
	return SUCCESS

