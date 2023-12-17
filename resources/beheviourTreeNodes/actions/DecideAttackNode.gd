extends ActionLeaf
# Decide attack node

var rng = RandomNumberGenerator.new()

func tick(actor: Node, blackboard: Blackboard) -> int:
	var battleManager:BattleManager = blackboard.get_value("battleManager")
	#var moveTiles = blackboard.get_value("tilesMovement").tiles
	var decisionWeightsAttack:Array = blackboard.get_value("decisionWeightsAttack")
	
#	var attackCountMovement = moveTiles.size()
#	var indexAttack = 0
#	var nextMoveTile = 0
	
	var wAtt = selectRandomAbility(actor, decisionWeightsAttack)
	if !wAtt:
		return FAILURE
	
	var prevAb = wAtt[0]
	for aux in wAtt:
		if aux[0].target_type == Ability.TargetTypes.Area:
			if prevAb[1] < aux[1]:
				prevAb = aux
		elif aux[0].target_type == Ability.TargetTypes.Priority:
			pass
		elif aux[0].target_type == Ability.TargetTypes.Selection:
			var possibleTarget = blackboard.get_value("possibleTarget")
			var attackTiles = battleManager.request_attack_range_for_enemy(actor, aux[2], aux[0]).tiles
			
			var target = null
			for at in attackTiles:
				if possibleTarget == at:
					target = possibleTarget
					break
					
			if !target:
				var randTile = rng.randi_range(0, attackTiles.size()-1)
				target = attackTiles[randTile]
			blackboard.set_value("attackTarget", target)
		
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
