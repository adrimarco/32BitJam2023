class_name BattlefieldGrid
extends Node3D

static var TILE_SIZE			:float = 0.56
static var TILE_PADDING			:float = 0.04
static var UNMARK_COLOR			:Color = Color(1.0, 1.0, 1.0)
static var PLAYER_MARK_COLOR	:Color = Color(0.0, 0.5, 1.0)
static var ENEMY_MARK_COLOR		:Color = Color(1.0, 0.25, 0.0)
static var SELECT_COLOR			:Color = Color(0.0, 1.0, 0.0)

@export var rows 		:int = 3
@export var columns		:int = 3
var grid_tiles			:Array[Array]
var mark_color			:Color = ENEMY_MARK_COLOR

func _ready():
	rotation.x = 0.0
	rotation.z = 0.0
	
	# Destroy sample texture
	$Sample.queue_free()
	
	rows = maxi(rows, 1)
	columns = maxi(columns, 1)
	
	var tile_texture:Texture2D = load("res://assets/environment/GridBasic.png")
	
	grid_tiles.resize(rows)
	for r in rows:
		grid_tiles[r].resize(columns)
		for c in columns:
			# Create tile
			var tile = Sprite3D.new()
			tile.position = Vector3(r * (TILE_SIZE + TILE_PADDING), 0, c * (TILE_SIZE + TILE_PADDING))
			
			tile.rotate_x(PI/2)
			tile.texture = tile_texture
			tile.centered = false
			
			add_child(tile)
			grid_tiles[r][c] = tile
		
	

func set_mark_color(player_color:bool):
	if player_color:
		mark_color = PLAYER_MARK_COLOR
	else:
		mark_color = ENEMY_MARK_COLOR
	

func get_tile_position(r, c) -> Vector3:
	var offset = Vector3(r * (TILE_SIZE + TILE_PADDING) + TILE_SIZE/2, 0.01, c * (TILE_SIZE + TILE_PADDING) + TILE_SIZE/2)
	
	offset = offset.rotated(Vector3(0.0, 1.0, 0.0), rotation.y)
	offset *= scale

	return global_position + offset

func unmark_all_tiles():
	for row in grid_tiles:
		for tile in row:
			tile.position.y = 0.0
			tile.modulate = UNMARK_COLOR
		

func mark_tiles(tiles_to_mark:Array[Vector2i]):
	for t in tiles_to_mark:
		mark_tile(t.x, t.y)

func mark_tile(r:int, c:int):
	if r < 0 or c < 0 or r >= grid_tiles.size() or c >= grid_tiles[r].size():
		return
	
	if grid_tiles[r][c] != null:
		grid_tiles[r][c].modulate = mark_color
		
	return

func select_tile(r:int, c:int):
	if r < 0 or c < 0 or r >= grid_tiles.size() or c >= grid_tiles[r].size():
		return
	
	if grid_tiles[r][c] != null:
		grid_tiles[r][c].modulate = SELECT_COLOR
		grid_tiles[r][c].position.y = 0.1

func unselect_tile(r:int, c:int):
	if r < 0 or c < 0 or r >= grid_tiles.size() or c >= grid_tiles[r].size():
		return
	
	if grid_tiles[r][c] != null:
		grid_tiles[r][c].modulate = mark_color
		grid_tiles[r][c].position.y = 0.0
