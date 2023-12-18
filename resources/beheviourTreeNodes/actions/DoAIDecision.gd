extends ActionLeaf

func tick(actor: Node, blackboard: Blackboard) -> int:
	# Get weights array and decide the ai turn
	var battleManager:BattleManager = blackboard.get_value("battleManager")
	var aiManager:AIManager = blackboard.get_value("aiManager")
#	var decisionWeightsMovement:Array = blackboard.get_value("decisionWeightsMovement")
#	var decisionWeightsAttack:Array = blackboard.get_value("decisionWeightsAttack")
	var att = blackboard.get_value("attack")
	if !att:
		aiManager.storeCharacterDecisionAITurn(null, null, [])
		return FAILURE
		
	#battleManager.do_action_movement(att[2])
	var targetAtt:Array[Vector2i] = blackboard.get_value("attackTarget")
	if targetAtt.size() <= 0:
		targetAtt = battleManager.request_attack_range_for_enemy(actor, att[2], att[0]).tiles

	# Movement -> att[2]
	# Attack ->  att[0], targetAtt
	
	if blackboard.get_value("rest"):
		aiManager.storeCharacterDecisionAITurn(null, null, targetAtt)
	else:
		aiManager.storeCharacterDecisionAITurn(att[2], att[0], targetAtt)
	
	return SUCCESS
