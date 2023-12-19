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
func tiles_in_same_row(grid:Array[Array], character_tile:Vector2i) -> TileCollection:
	# Variables for easier programming
	var row 	:= character_tile.y
	var _column	:= character_tile.x
	
	var tiles:TileCollection = TileCollection.new()
	for i in grid.size():
		# Add all tiles of same row
		tiles.tiles.append(Vector2i(i, row))
		
	return tiles

func tiles_in_same_column(grid:Array[Array], character_tile:Vector2i) -> TileCollection:
	# Variables for easier programming
	var row 	:= character_tile.y
	var column	:= character_tile.x
	
	var tiles:TileCollection = TileCollection.new()
	if grid.size() > row:
		for i in grid[row].size():
			# Add all tiles of same column
			tiles.tiles.append(Vector2i(column, i))
		
	return tiles

func all_tiles(grid:Array[Array], _character_tile:Vector2i) -> TileCollection:
	var tiles:TileCollection = TileCollection.new()
	# Add all tiles
	for column in grid.size():
		for row in grid[column].size():
			tiles.tiles.append(Vector2i(column, row))
			
	return tiles

func all_other_tiles(grid:Array[Array], character_tile:Vector2i) -> TileCollection:
	# Variables for easier programming
	var row 	:= character_tile.y
	var column	:= character_tile.x
	
	var tiles:TileCollection = TileCollection.new()
	# Add all tiles
	for c in grid.size():
		for r in grid[c].size():
			# Check is not character's tile
			if r != row or c != column:
				tiles.tiles.append(Vector2i(c, r))
			
		
	return tiles

func adjacent_tiles(grid:Array[Array], character_tile:Vector2i) -> TileCollection:
	# Variables for easier programming
	var row 	:= character_tile.y
	var column	:= character_tile.x
	
	var tiles:TileCollection = TileCollection.new()
	if column < grid.size() and row < grid[column].size():
		# Check surrounding tiles
		if row > 0:
			tiles.tiles.append(Vector2i(column, row-1))
		if row < grid[column].size()-1:
			tiles.tiles.append(Vector2i(column, row+1))
		if column > 0:
			tiles.tiles.append(Vector2i(column-1, row))
		if column < grid.size()-1:
			tiles.tiles.append(Vector2i(column+1, row))
		
	return tiles

func only_character_tile(_grid:Array[Array], character_tile:Vector2i) -> TileCollection:
	var tiles:TileCollection = TileCollection.new()
	# Only add character's tile
	tiles.tiles.append(character_tile)
	return tiles

func character_tile_and_adjacent(grid:Array[Array], character_tile:Vector2i) -> TileCollection:
	var tiles:TileCollection = only_character_tile(grid, character_tile)
	tiles.tiles.append_array(adjacent_tiles(grid, character_tile).tiles)
	
	return tiles

func same_column_and_row(grid:Array[Array], character_tile:Vector2i) -> TileCollection:
	var tiles		:= tiles_in_same_column(grid, character_tile)
	var same_row 	:= tiles_in_same_row(grid, character_tile)
	
	# Delete repeated tile
	for checked_tile in same_row.tiles:
		var array_index := tiles.tiles.find(checked_tile)
		if array_index > -1:
			tiles.tiles.remove_at(array_index)
			break
		
	# Combine arrays
	tiles.tiles.append_array(same_row.tiles)
	
	return tiles

func adjacent_tiles_in_column(grid:Array[Array], character_tile:Vector2i) -> TileCollection:
	# Variables for easier programming
	var row 	:= character_tile.y
	var column	:= character_tile.x
	
	var tiles:TileCollection = TileCollection.new()
	if column < grid.size() and row < grid[column].size():
		# Check surrounding tiles
		if row > 0:
			tiles.tiles.append(Vector2i(column, row-1))
		if row < grid[column].size()-1:
			tiles.tiles.append(Vector2i(column, row+1))
		
	return tiles


func only_back_column(grid:Array[Array], _character_tile:Vector2i) -> TileCollection:
	return tiles_in_same_column(grid, Vector2i(0, 0))

func only_front_column(grid:Array[Array], _character_tile:Vector2i) -> TileCollection:
	return tiles_in_same_column(grid, Vector2i(grid.size()-1, 0))

func _tile_from_enemy_field_at_n_distance(grid:Array[Array], character_tile:Vector2i, distance:int) -> TileCollection:
	# Variables for easier programming
	var row 	:= character_tile.y
	var column	:= character_tile.x
	
	var tiles := TileCollection.new()
	var distance_to_other_field = (grid.size()-1) - column
	
	# If do not reach field, return no tile
	if distance_to_other_field >= distance:
		return tiles
	
	tiles.tiles.append(Vector2i(grid.size() - (distance-distance_to_other_field), row))
	
	return tiles

func _tiles_from_enemy_field_at_n_distance_or_less(grid:Array[Array], character_tile:Vector2i, distance:int) -> TileCollection:
	var tiles := _tile_from_enemy_field_at_n_distance(grid, character_tile, distance)
	
	# Check if ability reaches other field
	if tiles.tiles.is_empty():
		return tiles
	
	var column = tiles.tiles[0].x + 1
	while column < grid.size():
		tiles.tiles.append(Vector2i(column, character_tile.y))
		column += 1
	
	return tiles

func tiles_at_three_or_less(grid:Array[Array], character_tile:Vector2i) -> TileCollection:
	return _tiles_from_enemy_field_at_n_distance_or_less(grid, character_tile, 3)

func tiles_at_two_or_less(grid:Array[Array], character_tile:Vector2i) -> TileCollection:
	return _tiles_from_enemy_field_at_n_distance_or_less(grid, character_tile, 2)

func column_at_three(grid:Array[Array], character_tile:Vector2i) -> TileCollection:
	var tile := _tile_from_enemy_field_at_n_distance(grid, character_tile, 3)
	
	if tile.tiles.is_empty():
		return tile
	
	return tiles_in_same_column(grid, tile.tiles[0])

func character_and_adjacent_rows(grid:Array[Array], character_tile:Vector2i) -> TileCollection:
	var surrounding_tiles := adjacent_tiles_in_column(grid, character_tile)
	
	var tiles := tiles_in_same_row(grid, character_tile)
	# Get all tiles from characters row and adjacent ones
	for t in surrounding_tiles.tiles:
		tiles.tiles.append_array(tiles_in_same_row(grid, t).tiles)
	
	return tiles

func _surrounding_tiles_at_n_or_less(grid:Array[Array], character_tile:Vector2i, n:int) -> TileCollection:
	var surrounding_tiles := adjacent_tiles_in_column(grid, character_tile)
	
	var tiles := _tiles_from_enemy_field_at_n_distance_or_less(grid, character_tile, n)
	# Get all tiles from tiles_at_two's tiles's columns
	for t in surrounding_tiles.tiles:
		tiles.tiles.append_array(_tiles_from_enemy_field_at_n_distance_or_less(grid, t, n).tiles)
	
	return tiles

func surrounding_tiles_at_two_or_less(grid:Array[Array], character_tile:Vector2i) -> TileCollection:
	return _surrounding_tiles_at_n_or_less(grid, character_tile, 2)

func surrounding_tiles_at_three_or_less(grid:Array[Array], character_tile:Vector2i) -> TileCollection:
	return _surrounding_tiles_at_n_or_less(grid, character_tile, 3)

func columns_at_two_or_less(grid:Array[Array], character_tile:Vector2i) -> TileCollection:
	var tiles_at_two := _tiles_from_enemy_field_at_n_distance_or_less(grid, character_tile, 2)
	
	if tiles_at_two.tiles.is_empty():
		return tiles_at_two
	
	var tiles := TileCollection.new()
	# Get all tiles from tiles_at_two's tiles's columns
	for t in tiles_at_two.tiles:
		tiles.tiles.append_array(tiles_in_same_column(grid, t).tiles)
	
	return tiles

func front_tile(grid:Array[Array], character_tile:Vector2i) -> TileCollection:
	return _tiles_from_enemy_field_at_n_distance_or_less(grid, character_tile, 1)

func able_to_move(grid:Array[Array], character_tile:Vector2i) -> TileCollection:
	# Get adjacent tiles
	var tiles:TileCollection = adjacent_tiles(grid, character_tile)
	
	# Remove tiles with other characters
	var i := 0
	while i < tiles.tiles.size():
		var tile_checked := tiles.tiles[i]
		if grid[tile_checked.x][tile_checked.y] != null:
			tiles.tiles.remove_at(i)
		else:
			i += 1
		
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
func closest_character_from_front(grid:Array[Array], tiles_checked:Array[Vector2i]) -> Array[Vector2i]:
	if tiles_checked.is_empty():
		return tiles_checked
	
	var closest_column := -1
	for t in tiles_checked:
		if grid[t.x][t.y] != null and t.x > closest_column:
			closest_column = t.x
	
	# Get all tiles from the closest column
	var tiles :Array[Vector2i] = []
	for t in tiles_checked:
		if t.x == closest_column and grid[t.x][t.y] != null:
			tiles.append(t)
			
	return tiles

func closest_character_from_back(grid:Array[Array], tiles_checked:Array[Vector2i]) -> Array[Vector2i]:
	if tiles_checked.is_empty():
		return tiles_checked
	
	var closest_column := grid.size()
	for t in tiles_checked:
		if grid[t.x][t.y] != null and t.x < closest_column:
			closest_column = t.x
	
	# Get all tiles from the closest column
	var tiles :Array[Vector2i] = []
	for t in tiles_checked:
		if t.x == closest_column and grid[t.x][t.y] != null:
			tiles.append(t)
			
	return tiles

func closest_character_from_back_on_each_row(grid:Array[Array], tiles_checked:Array[Vector2i]) -> Array[Vector2i]:
	if tiles_checked.is_empty():
		return tiles_checked
	
	var closest_column := Array()
	if grid.size() > 0:
		for row in grid[0].size():
			closest_column.append(grid.size())
	else:
		closest_column.append(grid.size())
		
	for t in tiles_checked:
		if grid[t.x][t.y] != null and t.x < closest_column[t.y]:
			closest_column[t.y] = t.x
	
	# Get closest tiles from each row
	var tiles :Array[Vector2i] = []
	for t in tiles_checked:
		if t.x == closest_column[t.y] and grid[t.x][t.y] != null:
			tiles.append(t)
			
	return tiles
