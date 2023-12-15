class_name BattleManager
extends Node3D

enum CharacterAction {None, Move, Attack, Rest}

@onready var battlefield:Battlefield	= $Battlefield
@onready var actionMenu:ActionMenu		= $actionMenu
@onready var tileSelector:TileSelector	= $TileSelector
@onready var aiManager:AIManager		= $aiManager
@onready var timer						:= $Timer

var attacking_character	:Character
var player_character	:bool
var actions_remaining 	:int
var waiting_for_action_animation	:bool

##### TEMPORAL ? ########
var movement_ability :Ability
#########################

signal requestAIAction

func _ready():
	
	connect("requestAIAction", Callable(aiManager, "getNextAction"))
	# Connect battlefield signal
	# When a playable character is ready to attack -> emit signal
	battlefield.connect("player_attack_turn", Callable(actionMenu, "_storeCharacterAttacking"))
	battlefield.connect("player_attack_turn", Callable(self, "set_attacking_character"))
	battlefield.connect("enemy_attack_turn", Callable(aiManager, "_storeCharacterAttacking"))
	battlefield.connect("enemy_attack_turn", Callable(self, "set_attacking_character"))
	battlefield.connect("player_dead", Callable(actionMenu, "characterDead"))
	
	actionMenu.connect("characterMove", Callable(self, "request_movement_range_for_player"))
	actionMenu.connect("characterAttack", Callable(self, "request_attack_range_for_player"))
	actionMenu.connect("characterRest", Callable(self, "do_action_rest"))
	actionMenu.connect("requestAbilityRange", Callable(self, "mark_ability_range"))
	actionMenu.connect("requestUnmarkRange", Callable(battlefield, "unmark_grid_tiles"))
	actionMenu.connect("characterAbility", Callable(self, "request_ability_range_for_player"))
	
	tileSelector.connect("selection_canceled", Callable(actionMenu, "set_input_enabled"))
	tileSelector.connect("movement_confirmed", Callable(self, "do_action_movement"))
	tileSelector.connect("attack_confirmed", Callable(self, "do_action_attack"))
	tileSelector.connect("selection_canceled", Callable(actionMenu, "hoverAbility"))
	
	aiManager.connect("executeMovementActionEnemy", Callable(self, "do_action_movement"))
	aiManager.connect("executeAttackActionEnemy", Callable(self, "do_action_attack"))
	aiManager.connect("executeRestActionEnemy", Callable(self, "do_action_rest"))
	
	actionMenu.initCharacterList()
	aiManager.initCharacterList()
	
	###### TEMPORAL ? ##########
	movement_ability = Ability.new()
	movement_ability.ability_range = Callable(RangeFunctions, "able_to_move")
	movement_ability.priority_func = Callable(RangeFunctions, "tile_empty")
	movement_ability.target_type = Ability.TargetTypes.Selection
	movement_ability.target_enemy_team = false
	############################
	
	bind_characters_signals()

func bind_characters_signals():
	var characters := battlefield.get_all_characters()
	
	for ch in characters:
		ch.connect("tile_movement_finished", Callable(self, "check_character_finished_action_animation"))
		ch.connect("attack_animation_finished", Callable(self, "check_character_finished_action_animation"))
	
func getCharactersFromBattleField(isPlayer:bool) -> Array[Character]:
	return battlefield.getCharactersByType(isPlayer)
	
func request_movement_range_for_enemy(ch:Character) -> RangeFunctions.TileCollection:
	var affected_tiles := battlefield.get_range_from_character_and_ability(ch, movement_ability, false, true)
	
	return affected_tiles

func request_attack_range_for_enemy(ch:Character, castTile:Vector2i = ch.grid_position, ab:Ability = ch.basic_attack) -> RangeFunctions.TileCollection:
	set_attacking_character(ch)
	
	var affected_tiles := battlefield.get_ability_range_from_position(ch, ab, castTile, false, true)
	
	return affected_tiles

func request_movement_range_for_player(ch:Character):
	var affected_tiles := battlefield.get_range_from_character_and_ability(ch, movement_ability, true, true)
	
	tileSelector.enable_tile_selector(battlefield.get_character_grid_from_character(ch), affected_tiles, movement_ability, true, CharacterAction.Move)

func request_attack_range_for_player(ch:Character):
	var affected_tiles := battlefield.get_range_from_character_and_ability(ch, ch.basic_attack, true, true)
	
	tileSelector.enable_tile_selector(battlefield.get_enemy_grid_from_character(ch), affected_tiles, ch.basic_attack, false, CharacterAction.Attack)

func mark_ability_range(ch:Character, abl:Ability):
	# Only show tiles in range
	battlefield.get_range_from_character_and_ability(ch, abl, true, false)

func request_ability_range_for_player(ch:Character, abl:Ability):
	# Check character has enough energy to cast ability
	if ch.mp < abl.cost:
		actionMenu.set_input_enabled()
		return
	
	var affected_tiles := battlefield.get_range_from_character_and_ability(ch, abl, false, true)
	
	tileSelector.enable_tile_selector(battlefield.get_grid_affected_by_ability(ch, abl), affected_tiles, abl, false, CharacterAction.Attack)

func do_action_movement(tiles_affected:Vector2i):
	if attacking_character == null:
		return
	print("Character moving to tile (" + str(tiles_affected.x) + ", " + str(tiles_affected.y) + ")")
	battlefield.set_character_tile(attacking_character, tiles_affected.x, tiles_affected.y)
	
	check_remaining_actions(1)

func do_action_attack(tiles_affected:Array[Vector2i], casted_ability:Ability):
	if attacking_character == null:
		return
	
	character_use_ability(attacking_character, casted_ability, tiles_affected)
	
	check_remaining_actions(2)

func do_action_rest():
	if attacking_character == null:
		return
	
	attacking_character.recover_extra_energy()
	
	check_remaining_actions(2)

func check_remaining_actions(actions_consumed:int):
	actions_remaining -= actions_consumed
	
	if player_character:
		actionMenu._storeCharacterAttacking(attacking_character)
		actionMenu.disable_input()
	
	waiting_for_action_animation = true
	timer.start()

func check_character_finished_action_animation(ch:Character):
	if ch == attacking_character && waiting_for_action_animation:
		resume_turn()

func resume_turn():
	if not waiting_for_action_animation:
		return
		
	waiting_for_action_animation = false
	if not timer.is_stopped():
		timer.stop()
	
	# If character did all their actions, battle continues
	if actions_remaining <= 0:
		attacking_character = null
		if player_character:
			actionMenu.showAbilityMenu(false)
			actionMenu.hideActionMenu()
		else:
			aiManager.endAITurn()
			
		battlefield.attack_finished()
	else:
		if player_character:
			actionMenu.set_input_enabled()
		else:
			requestAIAction.emit()

func set_attacking_character(ch:Character):
	if attacking_character == null or attacking_character != ch:
		actions_remaining = 2
		if ch != null:
			player_character = battlefield.searchCharacterIsPlayer(ch)
	
	attacking_character = ch

func character_use_ability(caster:Character, abl:Ability, targets:Array[Vector2i]):
	if caster == null or abl == null or caster.mp < abl.cost:
		return
	
	caster.play_attack_animation()
	
	var grid:BattlefieldGrid
	# Get target grid
	if abl.target_enemy_team:
		grid = battlefield.get_enemy_grid_from_character(caster)
	else:
		grid = battlefield.get_character_grid_from_character(caster)
	
	if abl.dmg_multiplier > 0.001:
		# Damage all targets
		for target in targets:
			if grid.grid_tiles[target.x][target.y] != null:
				grid.grid_tiles[target.x][target.y].damaged(caster, abl)
	print("Character attacking with basic attack (" + str(targets.size()) + " targets)")
	# Reduce energy cost
	caster.mp -= abl.cost
