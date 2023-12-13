class_name BattleManager
extends Node3D

enum CharacterAction {None, Move, Attack}

@onready var battlefield:Battlefield	= $Battlefield
@onready var actionMenu:ActionMenu		= $actionMenu
@onready var tileSelector:TileSelector	= $TileSelector
@onready var aiManager:AIManager		= $aiManager
var selected_action 	:CharacterAction
var attacking_character	:Character

##### TEMPORAL ? ########
var movement_ability :Ability
#########################

func _ready():
	# Connect battlefield signal
	# When a playable character is ready to attack -> emit signal
	battlefield.connect("player_attack_turn", Callable(actionMenu, "_storeCharacterAttacking"))
	battlefield.connect("enemy_attack_turn", Callable(aiManager, "_storeCharacterAttacking"))
	
	actionMenu.connect("characterMove", Callable(self, "request_movement_range_for_player"))
	
	tileSelector.connect("selection_canceled", Callable(actionMenu, "set_input_enabled"))
	tileSelector.connect("movement_confirmed", Callable(self, "do_action_movement"))
	
	actionMenu.initCharacterList()
	aiManager.initCharacterList()
	
	###### TEMPORAL ? ##########
	movement_ability = Ability.new()
	movement_ability.ability_range = Callable(RangeFunctions, "able_to_move")
	movement_ability.priority_func = Callable(RangeFunctions, "tile_empty")
	movement_ability.target_type = Ability.TargetTypes.Selection
	movement_ability.target_enemy_team = false
	############################

	
func getCharactersFromBattleField(isPlayer:bool) -> Array[Character]:
	return battlefield.getCharactersByType(isPlayer)

func request_movement_range_for_enemy(ch:Character) -> RangeFunctions.TileCollection:
	selected_action = CharacterAction.Move
	attacking_character = ch
	
	var affected_tiles := battlefield.get_range_from_character_and_ability(ch, movement_ability, false, true)
	
	return affected_tiles

func request_movement_range_for_player(ch:Character):
	selected_action = CharacterAction.Move
	attacking_character = ch
	
	var affected_tiles := battlefield.get_range_from_character_and_ability(ch, movement_ability, true, true)
	
	tileSelector.enable_tile_selector(battlefield.get_character_grid(ch), affected_tiles, movement_ability, true, CharacterAction.Move)

func do_action_movement(tiles_affected:Vector2i):
	battlefield.set_character_tile(attacking_character, tiles_affected.x, tiles_affected.y)
		
	# Resume turns
	battlefield.attack_finished()
	actionMenu.hideActionMenu()
