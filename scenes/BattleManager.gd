class_name BattleManager
extends Node3D

@onready var battlefield:Battlefield	= $Battlefield
@onready var actionMenu:ActionMenu		= $actionMenu
@onready var tileSelector:TileSelector	= $TileSelector
@onready var aiManager:AIManager		= $aiManager

func _ready():
	# Connect battlefield signal
	# When a playable character is ready to attack -> emit signal
	battlefield.connect("player_attack_turn", Callable(actionMenu, "_storeCharacterAttacking"))
	battlefield.connect("enemy_attack_turn", Callable(aiManager, "_storeCharacterAttacking"))
	
	actionMenu.connect("characterMove", Callable(self, "request_movement_range"))
	
	tileSelector.connect("selection_canceled", Callable(actionMenu, "set_input_enabled"))
	
	actionMenu.initCharacterList()
	aiManager.initCharacterList()

	
func getCharactersFromBattleField(isPlayer:bool) -> Array[Character]:
	return battlefield.getCharactersByType(isPlayer)

func request_movement_range(ch:Character):
	var ability := Ability.new()
	ability.ability_range = Callable(RangeFunctions, "able_to_move")
	ability.priority_func = Callable(RangeFunctions, "tile_empty")
	ability.target_type = Ability.TargetTypes.Selection
	ability.target_enemy_team = false
	
	var affected_tiles := battlefield.get_range_from_character_and_ability(ch, ability)
	
	tileSelector.enable_tile_selector(battlefield.get_character_grid(ch), affected_tiles, ability, true)
	
	return
