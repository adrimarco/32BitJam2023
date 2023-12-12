extends Node3D

var battlefield:Battlefield
var actionMenu
func _ready():
	battlefield = $Battlefield
	actionMenu = $actionMenu
	
	actionMenu.initCharacterList()
	
	
func getCharactersFromBattleField(isPlayer:bool) -> Array[Character]:
	return battlefield.getCharactersByType(isPlayer)
