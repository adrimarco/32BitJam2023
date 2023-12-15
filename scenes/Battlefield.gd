class_name Battlefield
extends Node3D

signal stop_preparing_attacks
signal resume_preparing_attacks
signal player_attack_turn(ch:Character)
signal enemy_attack_turn(ch:Character)
signal player_dead(ch:Character)
signal battle_finished(player_win:bool)

class CharacterData:
	var character		:Character
	var player_field	:bool:
		set(new_value):
			player_field = new_value
			if character.sprite != null:
				character.sprite.flip_h = not new_value
			
		

# Class variables
var characters 				:Array[CharacterData]
var attack_cue				:Array[Character]
var character_attacking		:bool

@onready var player_grid	:BattlefieldGrid	= $PlayerGrid
@onready var enemy_grid 	:BattlefieldGrid	= $EnemyGrid

func _init():
	character_attacking = false
	return
	
func _ready():
	enemy_grid.set_mark_color(false)
	player_grid.set_mark_color(true)
	
	# Load characters
	var player = load_character(preload("res://scenes/characters/Knight.tscn"), true)
	if player != null:
		set_character_tile(player, 1, 1, true)
		
	var player1 = load_character(preload("res://scenes/characters/Squeleton.tscn"), true)
	if player1 != null:
		set_character_tile(player1, 0, 1, true)
	
	var enemy = load_character(preload("res://scenes/characters/Squeleton.tscn"), false)
	if enemy != null:
		set_character_tile(enemy, 1, 1, true)	
	
	var enemy1 = load_character(preload("res://scenes/characters/Squeleton.tscn"), false)
	if enemy1 != null:
		set_character_tile(enemy1, 0, 1, true)	

	var enemy2 = load_character(preload("res://scenes/characters/Squeleton.tscn"), true)
	if enemy2 != null:
		set_character_tile(enemy2, 2, 1, true)	
		
	resume_preparing_attacks.emit()
	
	return
	
func _process(_delta):
	return
	

func character_ready_to_attack(ready_character:Character):
	# Stop attack meters
	stop_preparing_attacks.emit()
	
	if attack_cue.is_empty():
		attack_cue.append(ready_character)
	else:
		# Add character ordered in cue
		var added = false
		for i in attack_cue.size():
			if ready_character.attack_meter < attack_cue[i].attack_meter:
				attack_cue.insert(i, ready_character)
				added = true
				break
			
		if not added:
			attack_cue.append(ready_character)
		
	check_attack_cue()
	
	return

func check_attack_cue():
	# Attack cue cannot be checked while character attacking,
	# call attack_finished to enable it again and resume fight
	if character_attacking:
		return
		
	if attack_cue.is_empty():
		# Attacks finished, resume attack charge
		resume_preparing_attacks.emit()
	else:
		# Get the character that has to attack
		character_attacking = true
		var attacking_character = attack_cue.back()
		
		attacking_character.reset_attack_meter()

		# Check if character is player or not and emit attack turn signal
		if searchCharacterIsPlayer(attacking_character):
			print("######## Player attacking ########")
			player_attack_turn.emit(attacking_character)
		else:
			print("######## Enemy attacking ########")
			enemy_attack_turn.emit(attacking_character)
			
		attack_cue.pop_back()
	return

# Returns if a character is from player o an enemy
func searchCharacterIsPlayer(ch:Character) -> bool:
	for cIndex in characters:
		if cIndex.character == ch:
			return cIndex.player_field
	return false

func attack_finished():
	print("------ Character finished turn ------")
	character_attacking = false
	check_attack_cue()
	
	return

func character_died(ch:Character):
	var character_data	:CharacterData = null
	
	for c in characters:
		if c.character == ch:
			character_data = c
			break
		
	if character_data == null:
		return
	
	# Delete all references
	var player_character := character_data.player_field
	if player_character:
		player_grid.remove_character_from_grid(ch)
		player_dead.emit(ch)
	else:
		enemy_grid.remove_character_from_grid(ch)
	
	characters.erase(character_data)
	remove_from_attack_cue(ch)
	
	# Delete character
	ch.visible = false
	await get_tree().create_timer(1.0).timeout
	ch.queue_free()
	check_game_over()

func check_game_over():
	var player_alive 	:= false
	var enemy_alive 	:= false
	
	for c in characters:
		if c.player_field:
			player_alive = true
		else:
			enemy_alive = true
		
	# Check if one of the teams has been defeated
	if not player_alive:
		battle_finished.emit(false)
	elif not enemy_alive:
		battle_finished.emit(true)

func remove_from_attack_cue(ch:Character):
	attack_cue.erase(ch)

func load_character(character_scene:PackedScene, player_character:bool) -> Character:	
	var ch_data:CharacterData = CharacterData.new()
	ch_data.character = character_scene.instantiate()
	if ch_data.character == null:
		return null
		
	add_child(ch_data.character)
	characters.append(ch_data)
	ch_data.player_field = player_character
	
	# Bind signals
	ch_data.character.connect("attack_ready", Callable(self, "character_ready_to_attack"))
	ch_data.character.connect("character_dead", Callable(self, "character_died"))
	connect("resume_preparing_attacks", Callable(ch_data.character, "prepare_attack"))
	connect("stop_preparing_attacks", Callable(ch_data.character, "stop_preparing_attack"))
	
	return ch_data.character

func get_tile_position_in_character_battlefield(ch:Character, r:int, c:int) -> Vector3:
	var grid = get_character_grid_from_character(ch)
	var pos = grid.get_tile_position(r, c)
	
	return pos
	

func get_character_grid_from_character(ch:Character) -> BattlefieldGrid:
	var grid:BattlefieldGrid
	for i in characters.size():
		if characters[i].character == ch:
			# Check characters grid
			if characters[i].player_field:
				grid = player_grid
			else:
				grid = enemy_grid
			
			break
		
	return grid

func get_enemy_grid_from_character(ch:Character) -> BattlefieldGrid:
	var grid:BattlefieldGrid = get_character_grid_from_character(ch)
	
	if grid != null:
		# Check character's grid and return its enemy grid
		if grid == enemy_grid:
			grid = player_grid
		else:
			grid = enemy_grid
		
	return grid

func get_grid_affected_by_ability(ch:Character, ability:Ability) -> BattlefieldGrid:
	if ch == null or ability == null:
		return null
	
	var is_enemy_character 		:bool = not searchCharacterIsPlayer(ch)
	var grid :BattlefieldGrid
	# Get grid affected by ability
	if is_enemy_character == ability.target_enemy_team:
		grid = player_grid
	else:
		grid = enemy_grid
	
	return grid

func set_character_tile(ch:Character, r:int, c:int, teleport:bool = false) -> bool:
	# Get character grid
	var grid = get_character_grid_from_character(ch)
	if grid == null:
		return false
	
	return grid.set_character_tile(ch, r, c, teleport)	

func getCharactersByType(isPlayer:bool) -> Array[Character]:
	var chs:Array[Character] = []
	for ch in characters:
		if ch.player_field == isPlayer:
			chs.append(ch.character)
	return chs

func get_all_characters() -> Array[Character]:
	var ch_array:Array[Character] = []
	for ch in characters:
		ch_array.append(ch.character)
	return ch_array

func get_ability_range_from_position(ch:Character, ability:Ability, cast_tile:Vector2i, mark_range:bool = true, only_valid:bool = false) -> RangeFunctions.TileCollection:
	var target_field := get_grid_affected_by_ability(ch, ability)
	var is_player_field_target	:bool
	
	# Get matrix affected by ability
	if target_field == player_grid:
		is_player_field_target 	= true
	else:
		is_player_field_target 	= false
	
	var ability_range :RangeFunctions.TileCollection = ability.ability_range.call(target_field.grid_tiles, cast_tile)
	
	if mark_range:
		mark_ability_range(is_player_field_target, ability_range)
	
	# Check what tiles are valid inside the range
	if only_valid:
		if ability.target_type == Ability.TargetTypes.Priority:
			# In priority abilities, priority functions returns valid targets
			ability_range.tiles = ability.priority_func.call(target_field.grid_tiles, ability_range.tiles)
		else:
			# Check if each tile in range is valid
			var i :int = 0
			while i < ability_range.tiles.size():
				if ability.priority_func.call(target_field.grid_tiles, ability_range.tiles[i]):
					# Valid tile
					i += 1
				else:
					# Invalid tile, remove from list
					ability_range.tiles.remove_at(i)
				
		
	return ability_range

func get_range_from_character_and_ability(ch:Character, ability:Ability, mark_range:bool = true, only_valid:bool = false) -> RangeFunctions.TileCollection:
	if ch == null or ability == null:
		return null
	
	return get_ability_range_from_position(ch, ability, ch.grid_position, mark_range, only_valid)

func mark_ability_range(is_player_grid:bool, tiles:RangeFunctions.TileCollection):
	unmark_grid_tiles()
	
	if is_player_grid:
		player_grid.mark_tiles(tiles.tiles)
	else:
		enemy_grid.mark_tiles(tiles.tiles)

func unmark_grid_tiles():
	player_grid.unmark_all_tiles()
	enemy_grid.unmark_all_tiles()
