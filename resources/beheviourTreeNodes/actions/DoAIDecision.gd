extends ActionLeaf

func tick(actor: Node, blackboard: Blackboard) -> int:
	# Get weights array and decide the ai turn
	var battleManager:BattleManager = blackboard.get_value("battleManager")
	var aiManager:AIManager = blackboard.get_value("aiManager")
#	var decisionWeightsMovement:Array = blackboard.get_value("decisionWeightsMovement")
#	var decisionWeightsAttack:Array = blackboard.get_value("decisionWeightsAttack")
	var att = blackboard.get_value("attack")
	if !att:
		return FAILURE
		
	#battleManager.do_action_movement(att[2])
	var targetAtt = blackboard.get_value("attackTarget")
	if !targetAtt:
		targetAtt = battleManager.request_attack_range_for_enemy(actor, att[2], att[0])

	aiManager.storeCharacterDecisionAITurn(att[2], att[0], targetAtt)
	
	#battleManager.do_action_attack(attackTiles.tiles, att[0])
	
	# Movement -> att[2]
	# Attack -> attackTiles.tiles, att[0]
	return SUCCESS
