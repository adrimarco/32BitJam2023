extends ActionLeaf

func tick(actor: Node, blackboard: Blackboard) -> int:
	var battleManager:BattleManager = blackboard.get_value("battleManager")
	var attackTiles = blackboard.get_value("tiles").tiles
	if attackTiles.size() <= 0:
		blackboard.set_value("enemyAttacked", false)
		return FAILURE
	var a = blackboard.get_value("tiles").tiles[0]
	print("Attacking to (" + str(a.x) + ", " + str(a.y) + ")")
	battleManager.do_action_attack(attackTiles, actor.basic_attack)
	blackboard.set_value("enemyAttacked", true)
	return SUCCESS
