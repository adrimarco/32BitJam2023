extends ActionLeaf
# Decide attack node

var rng = RandomNumberGenerator.new()

func tick(actor: Node, blackboard: Blackboard) -> int:
	var battleManager:BattleManager = blackboard.get_value("battleManager")
	var moveTiles = blackboard.get_value("tilesMovement").tiles
	var decisionWeightsAttack:Array = blackboard.get_value("decisionWeightsAttack")
	
	var attackCountMovement = moveTiles.size()
#	var indexAttack = 0
#	var nextMoveTile = 0
	
	var wAtt = selectRandomAbility(actor, decisionWeightsAttack)
	if wAtt.size() <= 0:
		return FAILURE
	
	var prevAb = wAtt[0]
	for aux in wAtt:
		if aux[0].target_type == Ability.TargetTypes.Area:
			if prevAb[1] < aux[1]:
				prevAb = aux
		elif aux[0].target_type == Ability.TargetTypes.Priority:
			pass
		elif aux[0].target_type == Ability.TargetTypes.Selection:
			pass
	#	while indexAttack < decisionWeightsAttack.size() && nextMoveTile + attackCountMovement < decisionWeightsAttack.size():
	#		var weightAttack = decisionWeightsAttack[indexAttack]
	#
	#		indexAttack += 1 
	#		if indexAttack % attackCountMovement:
	#			nextMoveTile += attackCountMovement
		
	blackboard.set_value("attack", prevAb)
	return SUCCESS


func selectRandomAbility(actor, decisionWeightsAttack):
	var ab = null
	
	while ab == null:
		var rIdx = rng.randi_range(0, actor.abilities.size()-1)
		var aAux = actor.abilities[rIdx]
		if aAux.cost > actor.mp:
			continue
		var weightAtt = searchAbilityDecisionWeights(aAux, decisionWeightsAttack)
		if weightAtt.size() <= 0:
			return
		ab = weightAtt
	return ab
	
	
func searchAbilityDecisionWeights(ab:Ability, decisionWeightsAttack) ->Array:
	var atts = []
	for dAt in decisionWeightsAttack:
		if dAt[0] == ab && dAt[1] > 0:
			atts.append(dAt)
	return atts
