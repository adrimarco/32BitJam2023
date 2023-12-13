extends ActionLeaf



func tick(actor: Node, blackboard: Blackboard) -> int:
	blackboard.set_value("enemyMoved", false)
	return SUCCESS
