extends Node3D

var battlefield:Battlefield
var actionMenu:ActionMenu
func _ready():
	battlefield = $Battlefield
	actionMenu = $actionMenu
	# Connect battlefield signal
	# When a playable character is ready to attack -> emit signal
	battlefield.connect("player_attack_turn", Callable(actionMenu, "_storeCharacterAttacking"))
	
	actionMenu.initCharacterList()

	
func getCharactersFromBattleField(isPlayer:bool) -> Array[Character]:
	return battlefield.getCharactersByType(isPlayer)
