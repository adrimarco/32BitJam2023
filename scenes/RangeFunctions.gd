class_name RangeFunctionsSingleton
extends Node

class TileCollection:
	var tiles:Array[Vector2i]

# Note: rows visual representation in battle are equivalent to columns.
# Independently from the name, character_tile.x = columns and character_tile.y = row

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
