class_name AIManager

extends Node2D
var enemyCharacters:Array = []
var characterAttacking:bool = false
var characterRefAttacking:Character

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func initCharacterList():
	enemyCharacters = get_parent().getCharactersFromBattleField(false)

func endAITurn():
	if characterRefAttacking:
		characterRefAttacking.get_node("%BeheviourTree").enabled = false
	characterAttacking = false
	
func _storeCharacterAttacking(ch:Character) -> void:
	print("Attacking" + ch.character_name)
	characterAttacking = true
	characterRefAttacking = ch
	characterRefAttacking.get_node("%BeheviourTree").enabled = true
