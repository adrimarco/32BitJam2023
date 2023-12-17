extends ActionLeaf
# Request ability node

func tick(actor: Node, blackboard: Blackboard) -> int:
#	print("Request Attack")
	var battleManager:BattleManager = blackboard.get_value("battleManager")
	var moveTiles:RangeFunctions.TileCollection = blackboard.get_value("tilesMovement")
	var decisionWeightsAttack:Array = blackboard.get_value("decisionWeightsAttack")
	
	for ab in actor.abilities:
		# check all movements for each ability
		if !moveTiles:
			var movTile = actor.grid_position
			var attackTiles = battleManager.request_attack_range_for_enemy(actor, movTile, ab)
			blackboard.set_value("tiles", attackTiles)
			decisionWeightsAttack.append([ab, attackTiles.tiles.size(), movTile])
		else:
			for movTile in moveTiles.tiles:
	#			print("Moving to (" + str(movTile.x) + ", " + str(movTile.y) + ")")
				var attackTiles = battleManager.request_attack_range_for_enemy(actor, movTile, ab)
				blackboard.set_value("tiles", attackTiles)
				decisionWeightsAttack.append([ab, attackTiles.tiles.size(), movTile])
				#Print
	#			print("Ability " + ab.ability_name + " Targets: " + str(attackTiles.tiles.size()))
	#			var sAtkT =""
	#			for aT in attackTiles.tiles:
	#				sAtkT += "[" + str(aT.x)  + ", " + str(aT.y)  + "] "
	#			sAtkT += ""
	#			print("Tiles Attack: " + sAtkT)
				#Print
	return SUCCESS
