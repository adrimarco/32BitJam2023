class_name Battlefield
extends Node3D

signal stop_preparing_attacks
signal resume_preparing_attacks
signal player_attack_turn(ch:Character)
signal enemy_attack_turn(ch:Character)

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
	
	var enemy = load_character(preload("res://scenes/characters/Squeleton.tscn"), false)
	if enemy != null:
		set_character_tile(enemy, 1, 1, true)	
	
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
			player_attack_turn.emit(attacking_character)
		else:
			enemy_attack_turn.emit(attacking_character)
			
		attack_cue.pop_back()
	return

# Returns if a character is from player o an enemy
func searchCharacterIsPlayer(ch:Character) -> bool:
	for cIndex in characters:
		if cIndex.character == ch:
			return true
	return false

func attack_finished():
	character_attacking = false
	check_attack_cue()
	
	return

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
	connect("resume_preparing_attacks", Callable(ch_data.character, "prepare_attack"))
	connect("stop_preparing_attacks", Callable(ch_data.character, "stop_preparing_attack"))
	
	return ch_data.character

func get_tile_position_in_character_battlefield(ch:Character, r:int, c:int) -> Vector3:
	var grid = get_character_grid(ch)
	var pos = grid.get_tile_position(r, c)
	
	return pos
	

func get_character_grid(ch:Character) -> BattlefieldGrid:
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

func set_character_tile(ch:Character, r:int, c:int, teleport:bool = false) -> bool:
	# Get character grid
	var grid = get_character_grid(ch)
	if grid == null:
		return false
	
	# Check tile index is valid
	if r < 0 or r >= grid.rows or c < 0 or c >= grid.columns:
		return false
	
	# Check the indexes are correct and tile is empty
	if grid.grid_tiles[r] == null or grid.grid_tiles[r][c] != null:
		return false
	
	# Free previous tile
	if ch.grid_position.x >= 0 and ch.grid_position.y >= 0:
		grid.grid_tiles[ch.grid_position.x][ch.grid_position.y] = null
	
	# Move character
	grid.grid_tiles[r][c] = ch
	ch.move_to_world_position(get_tile_position_in_character_battlefield(ch, r, c), teleport)
	ch.grid_position = Vector2i(r, c)
	
	return true
	
	
func getCharactersByType(isPlayer:bool) -> Array[Character]:
	var chs:Array[Character] = []
	for ch in characters:
		if ch.player_field == isPlayer:
			chs.append(ch.character)
	return chs

func get_range_from_character_and_ability(ch:Character, ability:Ability) -> RangeFunctions.TileCollection:
	var is_enemy_character 		:bool = not searchCharacterIsPlayer(ch)
	var target_field 			:BattlefieldGrid
	var is_player_field_target	:bool
	
	# Get matrix affected by ability
	if is_enemy_character == ability.target_enemy_team:
		target_field 			= player_grid
		is_player_field_target 	= true
	else:
		target_field 			= enemy_grid
		is_player_field_target 	= false
	
	var ability_range :RangeFunctions.TileCollection = ability.ability_range.call(target_field.grid_tiles, ch.grid_position)
	
	mark_ability_range(is_player_field_target, ability_range)
	
	return ability_range

func mark_ability_range(is_player_grid:bool, tiles:RangeFunctions.TileCollection):
	unmark_grid_tiles()
	
	if is_player_grid:
		player_grid.mark_tiles(tiles.tiles)
	else:
		enemy_grid.mark_tiles(tiles.tiles)

func unmark_grid_tiles():
	player_grid.unmark_all_tiles()
	enemy_grid.unmark_all_tiles()
