class_name RangeFunctionsSingleton
extends Node

class TileCollection:
	var tiles:Array[Vector2i]

# Note: rows visual representation in battle are equivalent to columns.
# Independently from the name, character_tile.x = columns and character_tile.y = row

#########################################
## RANGE FUNCTIONS
## Return all tiles inside the range
#########################################
func enemies_in_same_row(grid:Array[Array], character_tile:Vector2i) -> TileCollection:
	# Variables for easier programming
	var row 	:= character_tile.y
	var _column	:= character_tile.x
	
	var tiles:TileCollection = TileCollection.new()
	if grid != null and grid.size() > 0:
		for i in grid.size():
			# Add all tiles of same row
			tiles.tiles.append(Vector2i(i, row))
	return tiles

func able_to_move(grid:Array[Array], character_tile:Vector2i) -> TileCollection:
	# Variables for easier programming
	var row 	:= character_tile.y
	var column	:= character_tile.x
	
	var tiles:TileCollection = TileCollection.new()
	if grid != null and column < grid.size() and row < grid[column].size():
		# Check surrounding tiles
		if row > 0 and grid[column][row-1] == null:
			tiles.tiles.append(Vector2i(column, row-1))
		if row < grid[column].size()-1 and grid[column][row+1] == null:
			tiles.tiles.append(Vector2i(column, row+1))
		if column > 0 and grid[column-1][row] == null:
			tiles.tiles.append(Vector2i(column-1, row))
		if column < grid.size()-1 and grid[column+1][row] == null:
			tiles.tiles.append(Vector2i(column+1, row))
	return tiles

#########################################
## AREA AND SELECTION FUNCTIONS
## Return wheter a tile satisfy a condition
#########################################
func character_in_tile(grid:Array[Array], tile_checked:Vector2i) -> bool:
	if tile_checked.x < 0 or tile_checked.x >= grid.size() or tile_checked.y < 0 or tile_checked.y >= grid[tile_checked.x].size():
		return false
	
	return grid[tile_checked.x][tile_checked.y] != null

func tile_empty(grid:Array[Array], tile_checked:Vector2i) -> bool:
	if tile_checked.x < 0 or tile_checked.x >= grid.size() or tile_checked.y < 0 or tile_checked.y >= grid[tile_checked.x].size():
		return false
	
	return grid[tile_checked.x][tile_checked.y] == null
	
#########################################
## PRIORITY FUNCTIONS
## Given some tiles, return specific tile/s
#########################################
#func tile_empty(grid:Array[Array], tiles_checked:Array[Vector2i]) -> Array[Vector2i]:
