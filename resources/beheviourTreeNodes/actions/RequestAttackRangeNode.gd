extends ActionLeaf
# Request attack node

func tick(actor: Node, blackboard: Blackboard) -> int:
#	print("Request Attack")
	var battleManager:BattleManager = blackboard.get_value("battleManager")
	var moveTiles:RangeFunctions.TileCollection = blackboard.get_value("tilesMovement")
	var decisionWeightsAttack:Array = blackboard.get_value("decisionWeightsAttack")
	# check all movements
	if !moveTiles:
		var movTile = actor.grid_position
		var attackTiles = battleManager.request_attack_range_for_enemy(actor, movTile)
		blackboard.set_value("tiles", attackTiles)
		decisionWeightsAttack.append([actor.basic_attack, attackTiles.tiles.size(), movTile])
		return SUCCESS
		
	for movTile in moveTiles.tiles:
#		print("Moving to (" + str(movTile.x) + ", " + str(movTile.y) + ")")
		var attackTiles = battleManager.request_attack_range_for_enemy(actor, movTile)
		blackboard.set_value("tiles", attackTiles)
		decisionWeightsAttack.append([actor.basic_attack, attackTiles.tiles.size(), movTile])
		#Print
#		print("Targets: " + str(attackTiles.tiles.size()))
#		var sAtkT =""
#		for aT in attackTiles.tiles:
#			sAtkT += "[" + str(aT.x)  + ", " + str(aT.y)  + "] "
#		sAtkT += ""
#		print("Tiles Attack: " + sAtkT)
		#Print
	return SUCCESS
