extends ActionLeaf

# TargetEnemyByLowerHealth
func tick(actor: Node, blackboard: Blackboard) -> int:
	var players:Array[Character] = blackboard.get_value("players")
	
	var lessHealth:Character = players[0]
	
	# Search the player with less health
	for p in players:
		if lessHealth.hp > p.hp:
			lessHealth = p
			
	blackboard.set_value("possibleTarget", [lessHealth.grid_position])
	return SUCCESS
