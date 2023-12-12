extends Node3D

@onready var battlefield:Battlefield	= $Battlefield
@onready var actionMenu:ActionMenu		= $actionMenu

func _ready():
	# Connect battlefield signal
	# When a playable character is ready to attack -> emit signal
	battlefield.connect("player_attack_turn", Callable(actionMenu, "_storeCharacterAttacking"))
	actionMenu.connect("characterMove", Callable(self, "request_movement_range"))
	
	actionMenu.initCharacterList()

	
func getCharactersFromBattleField(isPlayer:bool) -> Array[Character]:
	return battlefield.getCharactersByType(isPlayer)

func request_movement_range(ch:Character):
	var ability := Ability.new()
	ability.ability_range = Callable(RangeFunctions, "able_to_move")
	ability.target_enemy_team = false
	
	var affected_tiles := battlefield.get_range_from_character_and_ability(ch, ability).tiles
	
	
	return
