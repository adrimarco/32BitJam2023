extends ActionLeaf
# Decide movement node

var rng = RandomNumberGenerator.new()

func tick(actor: Node, blackboard: Blackboard) -> int:
	#var battleManager:BattleManager = blackboard.get_value("battleManager")
	var moveTiles = blackboard.get_value("tilesMovement").tiles
	var decisionWeightsMovement:Array = blackboard.get_value("decisionWeightsMovement")
	var movementRandom = rng.randi_range(0, 100)
#	print("Random " + str(movementRandom) + " Agg " + str(actor.aggressivity))
	
	if actor.aggressivity >= 50:
		if movementRandom < actor.aggressivity && movementRandom >= actor.aggressivity/2:
			# no change line
			var tilePos = moveSameLine(moveTiles, actor)
			if !tilePos:
				return FAILURE
			decisionWeightsMovement.append(tilePos)
#			print("no change line " + str(decisionWeightsMovement[0].x) + ", " + str(decisionWeightsMovement[0].y))
			return SUCCESS
	else:
		if movementRandom > actor.aggressivity && movementRandom <= actor.aggressivity*1.5:
			# no change line
			var tilePos = moveSameLine(moveTiles, actor)
			if !tilePos:
				return FAILURE
			decisionWeightsMovement.append(tilePos)
#			print("no change line " + str(decisionWeightsMovement[0].x) + ", " + str(decisionWeightsMovement[0].y))
			return SUCCESS
	if movementRandom <= actor.aggressivity:
		# Go forward if possible
		var tilePos = getForwardTile(moveTiles, actor)
		if !tilePos:
			return FAILURE
		decisionWeightsMovement.append(tilePos)
#		print("Go forward " + str(decisionWeightsMovement[0].x) + ", " + str(decisionWeightsMovement[0].y))
		return SUCCESS
	else:
		# Go back if possible
		var tilePos = getBackwardTile(moveTiles, actor)
		if !tilePos:
			return FAILURE
		decisionWeightsMovement.append(tilePos) 
#		print("Go back " + str(decisionWeightsMovement[0].x) + ", " + str(decisionWeightsMovement[0].y))
		return SUCCESS


func getSidewaysTile(moveTiles, actor) ->Array:
	var sidewayT:Array = []
	for t in moveTiles:
		if actor.grid_position.x == t.x:
			sidewayT.append(t)
		
	return sidewayT

func getForwardTile(moveTiles, actor):
	for t in moveTiles:
		if  actor.grid_position.x <= 2 && actor.grid_position.x <= t.x:
			return t
	return
	
func getBackwardTile(moveTiles, actor):
	for t in moveTiles:
		if  actor.grid_position.x >= 0 && actor.grid_position.x >= t.x:
			return t
	return
	
func moveSameLine(moveTiles, actor):
	var sidewayT = getSidewaysTile(moveTiles, actor)
	if sidewayT.size() <= 0:
		return
	if sidewayT.size() == 1:
		return sidewayT[0]
	var randomTile = rng.randi_range(0, sidewayT.size()-1)
	return sidewayT[randomTile]
