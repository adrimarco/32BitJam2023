class_name HasMovedNode extends ConditionLeaf

func tick(_actor: Node, blackboard: Blackboard) -> int:
	if blackboard.get_value("enemyMoved"):
		print("Once moved")
		return FAILURE
	else:
		print("no moved")
		return SUCCESS
