extends ActionLeaf

@onready var battleManager = get_tree().get_root().get_node("BattleManager")

func tick(actor: Node, blackboard: Blackboard) -> int:
	print("Request Movement")
	blackboard.set_value("battleManager", battleManager)
	var tiles:RangeFunctions.TileCollection = battleManager.request_movement_range_for_enemy(actor)
	blackboard.set_value("tiles", tiles)
	if tiles.tiles.size() <= 0:
		return FAILURE
	return SUCCESS

