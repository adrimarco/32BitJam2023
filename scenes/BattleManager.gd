class_name BattleManager
extends Node3D

enum CharacterAction {None, Move, Attack, Rest}

@onready var battlefield:Battlefield	= $SubViewportContainer/SubViewport/Battlefield
@onready var actionMenu:ActionMenu		= $SubViewportContainer/SubViewport/actionMenu
@onready var tileSelector:TileSelector	= $SubViewportContainer/SubViewport/TileSelector
@onready var aiManager:AIManager		= $SubViewportContainer/SubViewport/aiManager
@onready var timer						:= $SubViewportContainer/SubViewport/Timer

var attacking_character	:Character
var player_character	:bool
var actions_remaining 	:int
var waiting_for_action_animation	:bool

##### TEMPORAL ? ########
var movement_ability :Ability
#########################

signal requestAIAction
signal player_win_battle

func _ready():
	connect("requestAIAction", Callable(aiManager, "getNextAction"))
	
	# Connect children signal
	battlefield.connect("player_attack_turn", Callable(actionMenu, "_storeCharacterAttacking"))
	battlefield.connect("player_attack_turn", Callable(self, "set_attacking_character"))
	battlefield.connect("enemy_attack_turn", Callable(aiManager, "_storeCharacterAttacking"))
	battlefield.connect("enemy_attack_turn", Callable(self, "set_attacking_character"))
	battlefield.connect("player_dead", Callable(actionMenu, "characterDead"))
	battlefield.connect("resume_preparing_attacks", Callable(actionMenu, "resumePreparingAttacks"))
	battlefield.connect("battle_finished", Callable(self, "end_battle"))
	
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
	var affected_tiles := battlefield.get_ability_range_from_position(ch, ab, castTile, false, true)
	
	return affected_tiles

func request_movement_range_for_player(ch:Character):
	# Check character is not stunned
	if ch.has_effects([AbilityEffect.EffectType.Stun]):
		actionMenu.set_input_enabled()
		return
	
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
	if ch.mp < ch.get_ability_cost_from_character(abl):
		actionMenu.set_input_enabled()
		return
	
	var affected_tiles := battlefield.get_range_from_character_and_ability(ch, abl, false, true)
	
	tileSelector.enable_tile_selector(battlefield.get_grid_affected_by_ability(ch, abl), affected_tiles, abl, false, CharacterAction.Attack)

func do_action_movement(tiles_affected:Vector2i):
	if attacking_character == null or attacking_character.has_effects([AbilityEffect.EffectType.Stun]):
		check_remaining_actions(0)
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
	
	attacking_character.recover_energy()
	attacking_character.play_attack_animation()
	
	check_remaining_actions(2)

func check_remaining_actions(actions_consumed:int):
	actions_remaining -= actions_consumed
	
	if player_character:
		actionMenu._storeCharacterAttacking(attacking_character)
		actionMenu.disable_input()
	
	waiting_for_action_animation = true
	if actions_consumed > 0:
		timer.start(5.0)
	else:
		timer.start(0.5)

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
		# Update effects when character turn's end
		attacking_character.update_effects_duration(AbilityEffect.DurationType.Turns, 1)
		
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
	if caster == null or abl == null or caster.mp < caster.get_ability_cost_from_character(abl):
		return
	
	caster.play_attack_animation()
	
	
	var grid:BattlefieldGrid
	# Get target grid
	if abl.target_enemy_team:
		grid = battlefield.get_enemy_grid_from_character(caster)
	else:
		grid = battlefield.get_character_grid_from_character(caster)
	
	# Damage all targets
	for target in targets:
		var characterTarget:Character = grid.grid_tiles[target.x][target.y]
		if characterTarget != null:
			if abl.dmg_multiplier > 0.001:
				characterTarget.damaged(caster, abl)
			add_ability_effects_to_character(characterTarget, abl.effects_target)
			
			#Play ability animation at the target position
			abl.play_ability_animation(characterTarget)
			
			# Selection abilities can only affect one target
			if abl.target_type == Ability.TargetTypes.Selection:
				break
	print("Character attacking with " + abl.ability_name + " (" + str(targets.size()) + " targets)")
	
	# Add effects to caster
	add_ability_effects_to_character(caster, abl.effects_caster)
	
	# Reduce energy cost
	caster.mp -= caster.get_ability_cost_from_character(abl)

func push_character_trough_row(ch:Character, forward:bool):
	if ch == null:
		return
		
	var new_tile := ch.grid_position
	new_tile.x += 1 if forward else -1
	
	print("Character pushed to tile (" + str(new_tile.x) + ", " + str(new_tile.y) + ")")
	if battlefield.set_character_tile(ch, new_tile.x, new_tile.y):
		await ch.tile_movement_finished
	
	return

func add_ability_effects_to_character(ch:Character, ability_effects:Array[AbilityEffect]):
	if ch == null:
		return
	
	for e in ability_effects:
		if e.dur_type == AbilityEffect.DurationType.Immediate:
			resolve_immediate_effect(ch, e)
		else:
			ch.add_special_effect(e)

func resolve_immediate_effect(ch:Character, effect:AbilityEffect):
	if effect.type == AbilityEffect.EffectType.PushBack:
		push_character_trough_row(ch, false)
	elif effect.type == AbilityEffect.EffectType.PushFront:
		push_character_trough_row(ch, true)
	elif effect.type == AbilityEffect.EffectType.RecovHp:
		@warning_ignore("narrowing_conversion")
		ch.recover_health(ch.maxhp * (effect.value / 100.0))
	elif effect.type == AbilityEffect.EffectType.RecovMp:
		@warning_ignore("narrowing_conversion")		
		ch.recover_energy(ch.maxmp * (effect.value / 100.0))
	elif effect.type == AbilityEffect.EffectType.Purify:
		ch.remove_negative_effects()

func end_battle(player_win:bool):
	if player_win:
		print("VICTORY!!")
		player_win_battle.emit()
	else:
		print("DEFEATED...")
		player_win_battle.emit()
