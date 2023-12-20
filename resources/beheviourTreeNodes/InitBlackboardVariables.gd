extends ActionLeaf

var battleManager 	= null
var aiManager 		= null

func tick(_actor: Node, blackboard: Blackboard) -> int:
	if battleManager == null:
		battleManager = get_tree().get_root().get_node("BattleManager")
		aiManager = battleManager.get_node("%aiManager")
		
	#blackboard.set_value("enemyMoved", false)
	blackboard.set_value("battleManager", battleManager)
	blackboard.set_value("aiManager", aiManager)
	blackboard.set_value("decisionWeightsMovement", [])
	blackboard.set_value("decisionWeightsAttack", [])
	blackboard.set_value("players", battleManager.getCharactersFromBattleField(true))
	var attTarget:Array[Vector2i] = []
	blackboard.set_value("attackTarget", attTarget)
	blackboard.set_value("rest", false)
	
	return SUCCESS
