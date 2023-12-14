class_name HasAttackedNode extends ConditionLeaf


func tick(_actor: Node, blackboard: Blackboard) -> int:
	if blackboard.get_value("enemyAttacked"):
		return FAILURE
	else:
		return SUCCESS
