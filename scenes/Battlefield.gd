class_name Battlefield
extends Node3D

signal stop_preparing_attacks
signal resume_preparing_attacks
signal character_attack_turn(ch:Character)

class CharacterData:
	var character		:Character
	var player_field	:bool:
		set(new_value):
			player_field = new_value
			if character.sprite != null:
				character.sprite.flip_h = not new_value
			
		

# Class variables
var characters 				:Array[CharacterData]
var player_field			:Array[Array]
var enemy_field				:Array[Array]
var attack_cue				:Array[Character]
var character_attacking		:bool

@onready var player_grid	:BattlefieldGrid	= $PlayerGrid
@onready var enemy_grid 	:BattlefieldGrid	= $EnemyGrid

func _init():
	character_attacking = false
	return
	
func _ready():
	$EnemyGrid.scale = Vector3(-1.0, 1.0, 1.0)
	
	# Create player_field matrix
	player_field.resize(player_grid.rows)
	for i in player_grid.rows:
		player_field[i].resize(player_grid.columns)
	
	# Create enemy_field matrix
	enemy_field.resize(enemy_grid.rows)
	for i in enemy_grid.rows:
		enemy_field[i].resize(enemy_grid.columns)
	
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
		character_attack_turn.emit(attacking_character)
		attack_cue.pop_back()
	return


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
	
	# Get field matrix
	var matrix
	if grid == player_grid:
		matrix = player_field
	else:
		matrix = enemy_field
	
	# Check the indexes are correct and tile is empty
	if matrix == null or matrix[r] == null or matrix[r][c] != null:
		return false
	
	# Free previous tile
	if ch.grid_position.x >= 0 and ch.grid_position.y >= 0:
		matrix[ch.grid_position.x][ch.grid_position.y] = null
	
	# Move character
	matrix[r][c] = ch
	ch.move_to_world_position(get_tile_position_in_character_battlefield(ch, r, c), teleport)
	ch.grid_position = Vector2i(r, c)
	
	return true
