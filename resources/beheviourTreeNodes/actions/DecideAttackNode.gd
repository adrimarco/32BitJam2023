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
		blackboard.set_value("rest", true)
		return SUCCESS
	
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
			
			var target:Array[Vector2i] = []
			if possibleTarget:
				for at in attackTiles:
					if possibleTarget[0] == at:
						target.append(at)
						break
					
			if target.size() <= 0:
				var randTile = rng.randi_range(0, attackTiles.size()-1)
				target.append(attackTiles[randTile])
			blackboard.set_value("attackTarget", target)
		
	blackboard.set_value("attack", prevAb)
	return SUCCESS


func selectRandomAbility(actor:Character, decisionWeightsAttack):
	var possibleAbilities:Array = []
	for pAb in actor.abilities :
		if actor.get_ability_cost_from_character(pAb) > actor.mp:
			continue
			
		var weightAtt = searchAbilityDecisionWeights(pAb, decisionWeightsAttack)
		if weightAtt.size() <= 0:
			continue
			
		possibleAbilities.append(weightAtt)
		
	if possibleAbilities.size() > 0:
		var rIdx = rng.randi_range(0, possibleAbilities.size()-1)
		return possibleAbilities[rIdx]
		
	# Check enemy basic attack
	var weightAtt = searchAbilityDecisionWeights(actor.basic_attack, decisionWeightsAttack)
	if weightAtt.size() <= 0:
		return null
	return weightAtt
	
	
	
func searchAbilityDecisionWeights(ab:Ability, decisionWeightsAttack) ->Array:
	var atts = []
	for dAt in decisionWeightsAttack:
		if dAt[0] == ab && dAt[1] > 0:
			atts.append(dAt)
	return atts
