class_name TileSelector
extends Node3D

signal selection_canceled
signal movement_confirmed(tile:Vector2i)
signal attack_confirmed(tiles:Array[Vector2i])

@onready var timer			:= $SelectionTime

var selector_enabled		:bool
var player_field_active		:bool
var selected_ability		:Ability
var active_grid				:BattlefieldGrid
var tiles_available			:RangeFunctions.TileCollection
var current_selection		:Array[Vector2i]
var selected_action			:BattleManager.CharacterAction

func _ready():
	selector_enabled = false
	selected_action = BattleManager.CharacterAction.None

# Enable tile selection for an ability and return if there is at least one valid target
func enable_tile_selector(grid:BattlefieldGrid, tiles:RangeFunctions.TileCollection, ability:Ability, is_player_field:bool, a:BattleManager.CharacterAction) -> bool:
	selected_action 	= a
	player_field_active	= is_player_field
	active_grid 		= grid
	selected_ability 	= ability
	tiles_available 	= tiles
	
	# Activate input after a short time
	selection_cooldown()
	
	current_selection.resize(0)
	if tiles.tiles.is_empty():
		current_selection.append(Vector2i(-1, -1))
		
	else:
		var exists_valid_target := false
		# Selects a initial tile, if possible
		if selected_ability.target_type == Ability.TargetTypes.Area:
			# Save all tiles that satisfy the condition
			for tile_checked in tiles_available.tiles:
				if selected_ability.priority_func.call(active_grid.grid_tiles, tile_checked):
					current_selection.append(tile_checked)
					exists_valid_target = true
				
		elif selected_ability.target_type == Ability.TargetTypes.Selection:
			# Save first tile that satisfy the condition
			for tile_checked in tiles_available.tiles:
				if selected_ability.priority_func.call(active_grid.grid_tiles, tile_checked):
					current_selection.append(tile_checked)
					exists_valid_target = true
					break
		elif selected_ability.target_type == Ability.TargetTypes.Priority:
			# Save the tiles specified by the condition
			current_selection.append_array(selected_ability.priority_func.call(active_grid.grid_tiles, tiles_available.tiles))
			exists_valid_target = not current_selection.is_empty()
			
		else:
			current_selection.append(Vector2i(-1, -1))
		
		# Update selected tiles
		for t in current_selection:
			active_grid.select_tile(t.x, t.y)
		return exists_valid_target
		
	return false

func enable_selection():
	selector_enabled = true

func selection_cooldown():
	selector_enabled = false
	timer.start()
	
func _process(_delta):
	if not selector_enabled:
		return
	
	if not Input.is_anything_pressed():
		return
	
	if selected_ability.target_type == Ability.TargetTypes.Selection:
		# Check if at least one valid tile was found
		if current_selection[0].x > -1:
			# Player can choose target
			if Input.is_action_just_pressed("move_up"):
				select_next_tile_up()
			elif Input.is_action_just_pressed("move_down"):
				select_next_tile_down()
			elif Input.is_action_just_pressed("move_right"):
				if player_field_active:
					select_next_tile_right()
				else:
					select_next_tile_left()
			elif Input.is_action_just_pressed("move_left"):
				if player_field_active:
					select_next_tile_left()
				else:
					select_next_tile_right()
	
	if Input.is_action_just_pressed("action_back"):
		selector_enabled = false
		active_grid.unmark_all_tiles()
		selection_canceled.emit()
		
	elif Input.is_action_just_pressed("action_accept"):
		if not current_selection.is_empty() and current_selection[0].x > -1:
			selector_enabled = false
			active_grid.unmark_all_tiles()
			
			if selected_action == BattleManager.CharacterAction.Move:
				movement_confirmed.emit(current_selection[0])
			elif selected_action == BattleManager.CharacterAction.Attack:
				attack_confirmed.emit(current_selection)


func select_next_tile_up():
	# Search a valid tile up in the same column
	var search_row		:int	= current_selection[0].y - 1
	
	while search_row >= 0:
		var tile_checked := Vector2i(current_selection[0].x, search_row)
		if is_tile_available_and_valid(tile_checked):
				# Tile found, unselect previous tile and select new one
				change_selected_tile(tile_checked)
				return
			
		search_row -= 1
	
	# Tile not found in the same column, check other columns
	search_row = current_selection[0].y - 1
	
	while search_row >= 0:
		for search_column in active_grid.rows:
			if search_column == current_selection[0].x:
				# Checked in previous loop, skip
				continue
				
			var tile_checked := Vector2i(search_column, search_row)
			if is_tile_available_and_valid(tile_checked):
					# Tile found, unselect previous tile and select new one
					change_selected_tile(tile_checked)
					return
				
		search_row -= 1
	

func select_next_tile_down():
	# Search a valid tile down in the same column
	var search_row		:int	= current_selection[0].y + 1
	
	while search_row < active_grid.columns:
		var tile_checked := Vector2i(current_selection[0].x, search_row)
		if is_tile_available_and_valid(tile_checked):
				# Tile found, unselect previous tile and select new one
				change_selected_tile(tile_checked)
				return
			
		search_row += 1
	
	# Tile not found in the same column, check other columns
	search_row = current_selection[0].y + 1
	
	while search_row < active_grid.columns:
		for search_column in active_grid.rows:
			if search_column == current_selection[0].x:
				# Checked in previous loop, skip
				continue
				
			var tile_checked := Vector2i(search_column, search_row)
			if is_tile_available_and_valid(tile_checked):
					# Tile found, unselect previous tile and select new one
					change_selected_tile(tile_checked)
					return
				
		search_row += 1

func select_next_tile_right():
	# Search a valid tile right in the same row
	var search_column	:int	= current_selection[0].x + 1
	
	while search_column < active_grid.rows:
		var tile_checked := Vector2i(search_column, current_selection[0].y)
		if is_tile_available_and_valid(tile_checked):
				# Tile found, unselect previous tile and select new one
				change_selected_tile(tile_checked)
				return
			
		search_column += 1
	
	# Tile not found in the same column, check other columns
	search_column = current_selection[0].x + 1
	
	while search_column < active_grid.rows:
		for search_row in active_grid.columns:
			if search_row == current_selection[0].y:
				# Checked in previous loop, skip
				continue
				
			var tile_checked := Vector2i(search_column, search_row)
			
			if is_tile_available_and_valid(tile_checked):
					# Tile found, unselect previous tile and select new one
					change_selected_tile(tile_checked)
					return
				
		search_column += 1

func select_next_tile_left():
	# Search a valid tile right in the same row
	var search_column	:int	= current_selection[0].x - 1
	
	while search_column >= 0:
		var tile_checked := Vector2i(search_column, current_selection[0].y)
		if is_tile_available_and_valid(tile_checked):
				# Tile found, unselect previous tile and select new one
				change_selected_tile(tile_checked)
				return
			
		search_column -= 1
	
	# Tile not found in the same column, check other columns
	search_column = current_selection[0].x - 1
	
	while search_column >= 0:
		for search_row in active_grid.columns:
			if search_row == current_selection[0].y:
				# Checked in previous loop, skip
				continue
				
			var tile_checked := Vector2i(search_column, search_row)
			if is_tile_available_and_valid(tile_checked):
					# Tile found, unselect previous tile and select new one
					change_selected_tile(tile_checked)
					return
				
		search_column -= 1

func is_tile_available(t:Vector2i) -> bool:
	for tile in tiles_available.tiles:
		if tile == t:
			return true
		
	return false

func unselect_tile():
	if current_selection[0].x >= 0:
		active_grid.unselect_tile(current_selection[0].x, current_selection[0].y)

func is_tile_available_and_valid(tile:Vector2i) -> bool:
	return is_tile_available(tile) and selected_ability.priority_func.call(active_grid.grid_tiles, tile)

func change_selected_tile(new_selection:Vector2i):
	unselect_tile()
	current_selection[0] = new_selection
	active_grid.select_tile(new_selection.x, new_selection.y)
