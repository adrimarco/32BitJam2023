class_name AIManager

extends Node2D
var enemyCharacters:Array = []
var characterAttacking:bool = false
var characterRefAttacking:Character
var movementAction:Vector2i
var attackAction:Ability = null
var attackRange:Array[Vector2i]
var decisionCompleted:bool = false


signal executeMovementActionEnemy(tile:Vector2i)
signal executeAttackActionEnemy(tiles:Array[Vector2i], ab:Ability)
signal executeRestActionEnemy

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func initCharacterList():
	enemyCharacters = get_parent().get_parent().get_parent().getCharactersFromBattleField(false)

func storeCharacterDecisionAITurn(movement, attack, attRange:Array[Vector2i]):
	if decisionCompleted:
		return
	
	if movement:
		movementAction = movement
	if attack:
		attackAction = attack
	attackRange = attRange
	decisionCompleted = true
	executeBehaviourTree(false)
	getNextAction()
	
func executeBehaviourTree(activateBT:bool):
	characterRefAttacking.get_node("%BeheviourTree").enabled = activateBT

func endAITurn():
	if characterRefAttacking:
		executeBehaviourTree(false)
		#characterRefAttacking.get_node("%Blackboard").set_value("enemyMoved", false)
	characterAttacking = false
	
func _storeCharacterAttacking(ch:Character) -> void:
	print("Attacking " + ch.character_name)
	characterAttacking = true
	characterRefAttacking = ch
	movementAction = Vector2i(-1, -1)
	attackAction = null
	decisionCompleted = false
	getNextAction()
	
func getNextAction():
	if !decisionCompleted:
		executeBehaviourTree(true)
		
	elif movementAction.x >= 0:
		executeMovementActionEnemy.emit(movementAction)
		movementAction = Vector2i(-1, -1)

	elif attackAction:
		executeAttackActionEnemy.emit(attackRange, attackAction)
		attackAction 	= null
		attackRange.clear()

	else:
		executeRestActionEnemy.emit()
