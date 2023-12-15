extends ActionLeaf

@onready var battleManager = get_tree().get_root().get_node("BattleManager")
@onready var aiManager = battleManager.get_node("aiManager")

func tick(actor: Node, blackboard: Blackboard) -> int:
	#blackboard.set_value("enemyMoved", false)
	blackboard.set_value("battleManager", battleManager)
	blackboard.set_value("aiManager", aiManager)
	blackboard.set_value("decisionWeightsMovement", [])
	blackboard.set_value("decisionWeightsAttack", [])
	#blackboard.set_value("agressivity", )
	
	return SUCCESS
