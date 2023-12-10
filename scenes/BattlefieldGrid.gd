class_name BattlefieldGrid
extends Node3D

static var TILE_SIZE	:float = 0.56
static var TILE_PADDING	:float = 0.04

@export var rows 		:int = 3
@export var columns		:int = 3

func _ready():
	rotation.x = 0.0
	rotation.z = 0.0
	
	# Destroy sample texture
	$Sample.queue_free()
	
	rows = maxi(rows, 1)
	columns = maxi(columns, 1)
	
	var tile_texture:Texture2D = load("res://assets/environment/GridBasic.png")
	
	for r in rows:
		for c in columns:
			# Create tile
			var tile = Sprite3D.new()
			tile.position = Vector3(r * (TILE_SIZE + TILE_PADDING), 0, c * (TILE_SIZE + TILE_PADDING))
			
			tile.rotate_x(PI/2)
			tile.texture = tile_texture
			tile.centered = false
			
			add_child(tile)
			
		
	

func get_tile_position(r, c) -> Vector3:
	var offset = Vector3(r * (TILE_SIZE + TILE_PADDING) + TILE_SIZE/2, 0.01, c * (TILE_SIZE + TILE_PADDING) + TILE_SIZE/2)
	
	offset = offset.rotated(Vector3(0.0, 1.0, 0.0), rotation.y)
	offset *= scale

	return global_position + offset
