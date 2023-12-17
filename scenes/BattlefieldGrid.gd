class_name BattlefieldGrid
extends Node3D

@onready var lucky_timer 		:= $LuckyTimer

static var TILE_SIZE			:float = 0.6
static var NORMAL_UNMARK_COLOR	:Color = Color(0.0, 0.0, 0.0)
static var LUCKY_UNMARK_COLOR	:Color = Color(0.659, 0.549, 0.0)
static var PLAYER_MARK_COLOR	:Color = Color(0.0, 0.5, 1.0)
static var ENEMY_MARK_COLOR		:Color = Color(1.0, 0.25, 0.0)
static var SELECT_COLOR			:Color = PLAYER_MARK_COLOR#Color(1.0, 0.96, 0.23)
static var LUCKY_TILES_COUNT	:int   = 2
static var LUCKY_TILE_EFFECTS	:Array[AbilityEffect.EffectType] = [AbilityEffect.EffectType.Lucky, 
								AbilityEffect.EffectType.DecMpCost, AbilityEffect.EffectType.StealHp]
static var LUCKY_TILE_EFF_VALUE	:Array[float] = [50.0, 25.0, 60.0]

@export var rows 		:int = 3
@export var columns		:int = 3
@export var invert		:bool = false
var grid_tiles			:Array[Array]
var grid_sprites		:Array[Array]
var grid_lucky_effects	:Array[Array]
var current_lucky_effects:Array[AbilityEffect.EffectType]
var mark_color			:Color = ENEMY_MARK_COLOR

func _ready():
	rotation.x = 0.0
	rotation.z = 0.0
	
	# Destroy sample texture
	$Sample.queue_free()
	
	rows = maxi(rows, 1)
	columns = maxi(columns, 1)
	
	var sprite_frame:Resource = load("res://resources/spriteFrames/tile.tres")
	
	grid_sprites.resize(rows)
	grid_tiles.resize(rows)
	grid_lucky_effects.resize(rows)
	for r in rows:
		grid_sprites[r].resize(columns)
		grid_tiles[r].resize(columns)
		grid_lucky_effects[r].resize(columns)
		
		for c in columns:
			# Create tile
			var tile = AnimatedSprite3D.new()
			tile.sprite_frames = sprite_frame
			tile.modulate = NORMAL_UNMARK_COLOR
			tile.animation = "normal"
			
			var grid_dir = -1.0 if invert else 1.0
			tile.position = Vector3(r * TILE_SIZE * grid_dir, 0, c * TILE_SIZE)
			tile.rotate_x(-PI/2)
			
			add_child(tile)
			grid_sprites[r][c] = tile
			grid_lucky_effects[r][c] = -1
		
	

func set_mark_color(player_color:bool):
	if player_color:
		mark_color = PLAYER_MARK_COLOR
	else:
		mark_color = ENEMY_MARK_COLOR
	

func get_tile_position(r, c) -> Vector3:
	if r < 0 or r >= rows or c < 0 or c >= columns:
		return global_position
	
	return grid_sprites[r][c].global_position

func unmark_all_tiles():
	for r in grid_sprites.size():
		for c in grid_sprites[r].size():
			var tile = grid_sprites[r][c]
			tile.position.y = 0.0
			tile.modulate = NORMAL_UNMARK_COLOR if grid_lucky_effects[r][c] == -1 else LUCKY_UNMARK_COLOR
			tile.stop()
			
		

func remove_character_from_grid(ch:Character):
	if ch == null:
		return
	
	# Check if the player is in the grid
	var ch_pos := ch.grid_position
	if grid_tiles[ch_pos.x][ch_pos.y] == ch:
		grid_tiles[ch_pos.x][ch_pos.y] = null
		ch.set_grid_position(Vector2i(-1, -1))

func set_character_tile(ch:Character, r:int, c:int, teleport:bool = false) -> bool:
	# Check tile index is valid
	if r < 0 or r >= rows or c < 0 or c >= columns:
		return false
	
	# Check the indexes are correct and tile is empty
	if grid_tiles[r] == null or grid_tiles[r][c] != null:
		return false
	
	# Free previous tile
	if ch.grid_position.x >= 0 and ch.grid_position.y >= 0:
		var previous_pos = ch.grid_position
		if grid_tiles[previous_pos.x][previous_pos.y] == ch:
			# Character was in this grid, free position
			grid_tiles[previous_pos.x][previous_pos.y] = null
	
	# Move character
	grid_tiles[r][c] = ch
	ch.move_to_world_position(get_tile_position(r, c), teleport)
	ch.grid_position = Vector2i(r, c)
	
	# Add effect to characters stepping on lucky tile
	ch.remove_tile_effects()
	if grid_lucky_effects[r][c] != -1:
		add_lucky_effect_to_character(r, c)
	
	return true

func add_lucky_effect_to_character(r: int, c:int):
	if r < 0 or c < 0 or r >= rows or c >= columns:
		return
	
	# Check there is a character on the tile and it is lucky
	if grid_lucky_effects[r][c] == -1 or grid_tiles[r][c] == null:
		return
	
	var type = grid_lucky_effects[r][c]
	var effect := EffectsContainer.get_effect(type as AbilityEffect.EffectType, LUCKY_TILE_EFF_VALUE[get_lucky_effect_index(type)], 1)
	
	grid_tiles[r][c].add_special_effect(effect)

func get_lucky_effect_index(type:AbilityEffect.EffectType) -> int:
	for i in LUCKY_TILE_EFFECTS.size():
		if LUCKY_TILE_EFFECTS[i] == type:
			return i
		
	return -1

func mark_tiles(tiles_to_mark:Array[Vector2i]):
	for t in tiles_to_mark:
		mark_tile(t.x, t.y)

func mark_tile(r:int, c:int):
	if r < 0 or c < 0 or r >= rows or c >= columns:
		return
	
	if grid_sprites[r][c] != null:
		grid_sprites[r][c].modulate = mark_color
		
	return

func select_tile(r:int, c:int):
	if r < 0 or c < 0 or r >= rows or c >= columns:
		return
	
	if grid_sprites[r][c] != null:
		#grid_sprites[r][c].modulate = SELECT_COLOR
		grid_sprites[r][c].play()

func unselect_tile(r:int, c:int):
	if r < 0 or c < 0 or r >= rows or c >= columns:
		return
	
	if grid_sprites[r][c] != null:
		#grid_sprites[r][c].modulate = mark_color
		grid_sprites[r][c].stop()

func change_lucky_tiles():
	var previous_tiles :Array[Vector2i] = []
	
	for r in grid_lucky_effects.size():
		for c in grid_lucky_effects[r].size():
			if grid_lucky_effects[r][c] != -1:
				previous_tiles.append(Vector2i(r, c))
				remove_lucky_tile(r, c)
			
		
	var lucky_tiles_placed := 0
	while lucky_tiles_placed < LUCKY_TILES_COUNT:
		var rand_row 	:= randi() % rows
		var rand_column := randi() % columns
		
		if not Vector2i(rand_row, rand_column) in previous_tiles and set_lucky_tile(rand_row, rand_column):
			lucky_tiles_placed += 1

func set_lucky_tile(r:int, c:int) -> bool:
	if r < 0 or r >= rows or c < 0 or c >= columns or grid_lucky_effects[r][c] != -1:
		return false
	
	# Get a random effect
	var rand_index 		:= randi()%LUCKY_TILE_EFFECTS.size()
	var lucky_effect 	:= LUCKY_TILE_EFFECTS[rand_index]
	
	# Prevent the effect to be repeated, unless there is no option
	while lucky_effect in current_lucky_effects and current_lucky_effects.size() < LUCKY_TILE_EFFECTS.size():
		rand_index		= (rand_index + 1) % LUCKY_TILE_EFFECTS.size()
		lucky_effect 	= LUCKY_TILE_EFFECTS[rand_index]
	
	# Add the effect to the tile and current effects array
	grid_lucky_effects[r][c] = lucky_effect
	current_lucky_effects.append(lucky_effect)
	update_lucky_tile_sprite(r, c)
	
	# If there is a character on it, receive effect
	if grid_tiles[r][c] != null:
		add_lucky_effect_to_character(r, c)
	
	return true

func update_lucky_tile_sprite(r:int, c:int):
	if r < 0 or r >= rows or c < 0 or c >= columns:
		return false
	
	if grid_lucky_effects[r][c] == -1:
		grid_sprites[r][c].animation = "normal"
		grid_sprites[r][c].modulate = NORMAL_UNMARK_COLOR
	else:
		grid_sprites[r][c].modulate = LUCKY_UNMARK_COLOR
		if grid_lucky_effects[r][c] == AbilityEffect.EffectType.DecMpCost:
			grid_sprites[r][c].animation = "energy"
		elif grid_lucky_effects[r][c] == AbilityEffect.EffectType.StealHp:
			grid_sprites[r][c].animation = "health"
		else:
			grid_sprites[r][c].animation = "luck"
		


func remove_lucky_tile(r:int, c:int) -> bool:
	if r < 0 or r >= rows or c < 0 or c >= columns:
		return false
	
	if grid_lucky_effects[r][c] != -1:
		# If there is a character on it, loose effect
		if grid_tiles[r][c] != null:
			grid_tiles[r][c].remove_tile_effects()
		
		# Remove effect from tile and current effects array
		current_lucky_effects.erase(grid_lucky_effects[r][c])
		grid_lucky_effects[r][c] = -1
		
		update_lucky_tile_sprite(r, c)
		
		return true
	
	return false

func pause_lucky_timer():
	lucky_timer.set_paused(true)

func unpause_lucky_timer():
	lucky_timer.set_paused(false)	
