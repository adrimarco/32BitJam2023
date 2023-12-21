class_name TournamentBoard
extends Node2D

signal activate_main_menu

@onready var fade_layer 	:= $CanvasLayer/ColorRect
@onready var anim_player	:= $AnimationPlayer
@onready var camera			:= $Camera2D
@onready var contenders_node:= $Contenders
@onready var round_1_markers:= $PaperPositions/Round1
@onready var round_2_markers:= $PaperPositions/Round2
@onready var round_3_markers:= $PaperPositions/Round3

static var PLAYER_TEAM_COLOR:= Color(0.35, 0.36, 0.72)
static var ENEMY_TEAM_COLOR	:= Color(0.41, 0.41, 0.41)

var battle_scene			:= preload("res://scenes/BattleManager.tscn")
var battle_node				:BattleManager = null
var tournament_round		:int
var player_characters		:Array[int]
var player_team				:int
var teams_array				:Array[Node]
var teams_playing			:Array[bool]
var board_positions			:Array[Array]
var teams_fought			:Array[int]

func _ready():
	fade_layer.color 	= Color(0.0, 0.0, 0.0, 1.0)
	
	teams_array 		= contenders_node.get_children()
	teams_playing.resize(teams_array.size())
	player_team 		= randi()%teams_array.size()
	camera.position		= Vector2(322, 576)
	
	tournament_round 	= 0
	
	for index in teams_array.size():
		set_cross_visibility(index, false)
	
	board_positions.resize(3)		
	board_positions[0] = round_1_markers.get_children()
	board_positions[1] = round_2_markers.get_children()
	board_positions[2] = round_3_markers.get_children()
	
	order_arrays()
	place_papers(true)
	tint_papers()
	
	await fade_screen(false)
	play_tournament_board_animation()
	

func play_tournament_board_animation():
	AudioPlayerInstance.play_music_by_index(AudioPlayerInstance.MENU_MUSIC)
	anim_player.play("show_board")
	await anim_player.animation_finished
	
	await fade_screen(true)
	move_camera_to_player_battle()
	fade_screen(false)
	await get_tree().create_timer(3.0).timeout
	
	load_battle()

func reset_camera_position_and_zoom():
	camera.position = Vector2(322, 576)
	camera.zoom		= Vector2(1, 1)
	pass


func set_player_characters(characters:Array[int]):
	player_characters.clear()
	player_characters = characters


func load_battle():
	# Get random team to fight against
	var enemy_team_index := randi() % CharactersContainer.teams_count
	
	while enemy_team_index in teams_fought:
		enemy_team_index = (enemy_team_index + 1) % CharactersContainer.teams_count
	
	teams_fought.append(enemy_team_index)
	
	# Load battle manager
	battle_node = battle_scene.instantiate()
	if battle_node:
		await fade_screen(true)
		# Bind signals
		battle_node.connect("player_win_battle", Callable(self, "next_round"))
		battle_node.connect("player_loose_battle", Callable(self, "back_to_main_menu"))
		
		camera.enabled = false
		get_tree().get_root().add_child(battle_node)
		battle_node.set_battle_teams([0, 0, 0], CharactersContainer.get_team_by_id(enemy_team_index))
		fade_screen(false)
		battle_node.start_battle()
	

func move_camera_to_player_battle():
	camera.zoom 	= Vector2(1.0, 1.0)
	var camera_pos :Vector2 = teams_array[player_team].position
	
	# Get the team that fights against
	var teams_being_checked	:= Array()
	var group_count 		:= 2*(tournament_round + 1)
	@warning_ignore("integer_division")
	var iterations			:= teams_array.size()/group_count
	for group_index in iterations:
		# Add teams fighting in the group
		var i := group_count*group_index
		while i < group_count*(group_index + 1):
			if teams_playing[i]:
				teams_being_checked.append(i)
			i += 1
		
		if player_team in teams_being_checked:
			break
		else:
			teams_being_checked.clear()
		
	if teams_being_checked.size() >= 2:
		# Calculate camera position and zoom
		teams_being_checked.erase(player_team)
		var other_team_pos = teams_array[teams_being_checked[0]].position
		var zoom := minf(1, 1 / (camera_pos.distance_to(other_team_pos)/400))
		camera.zoom = Vector2(zoom, zoom)
		
		camera_pos += teams_array[teams_being_checked[0]].position
		camera_pos /= 2
		
	camera.position = camera_pos + Vector2(0, 70)

func place_papers(place_player_paper:bool = false):
	if tournament_round == 0:
		for i in teams_array.size():
			if not place_player_paper and i == player_team:
				continue
				
			teams_playing[i] = true
			teams_array[i].position = get_paper_position(i)
		
	elif tournament_round == 1:
		for i in teams_array.size():
			if not teams_playing[i]:
				continue
			if not place_player_paper and i == player_team:
				continue
			
			@warning_ignore("integer_division")
			teams_array[i].position = get_paper_position(i/2)
		
	elif tournament_round == 2:
		for i in teams_array.size():
			if not teams_playing[i]:
				continue
			if not place_player_paper and i == player_team:
				continue
			
			@warning_ignore("integer_division")
			teams_array[i].position = get_paper_position(i/4)

func get_paper_position(index:int) -> Vector2:
	if tournament_round >= board_positions.size():
		return Vector2i(-1, -1)
	
	return board_positions[tournament_round][index % board_positions[tournament_round].size()].position

func tint_papers():
	for index in teams_array.size():
		var symbol := teams_array[index].get_node("Symbol")
		if symbol:
			symbol.modulate = PLAYER_TEAM_COLOR if index == player_team else ENEMY_TEAM_COLOR
	

func set_cross_visibility(index:int, new_visibility:bool):
	if index >= teams_array.size():
		return
	
	var cross_node = teams_array[index].get_node("Cross")
	if cross_node:
		cross_node.visible = new_visibility
	
	return

func fade_screen(to_black:bool) -> Signal:
	if to_black:
		anim_player.play("fade_animation")
	else:
		anim_player.play_backwards("fade_animation")
	
	return anim_player.animation_finished

func next_round():
	reset_camera_position_and_zoom()
	# Fade screen and eliminate battle node
	await fade_screen(true)
	battle_node.queue_free()
	battle_node = null
	camera.enabled = true
	
	# Update tournament board
	eliminate_teams()
	tournament_round += 1
	place_papers(true)
	
	await fade_screen(false)
	play_tournament_board_animation()

func back_to_main_menu():
	# Fade screen and eliminate battle node
	await fade_screen(true)
	if battle_node:
		battle_node.queue_free()
		battle_node = null
	
	activate_main_menu.emit()
	
func order_arrays():
	var sort_function := Callable(self, "sort_node")
	teams_array.sort_custom(sort_function)
	for markers in board_positions:
		markers.sort_custom(sort_function)
	

func sort_node(a:Node, b:Node):
	var half_screen := 360
	if a.position.x <= half_screen and b.position.x > half_screen:
		return true
	elif b.position.x <= half_screen and a.position.x > half_screen:
		return false
	else:
		return a.position.y <= b.position.y
	
func eliminate_teams():
	var teams_being_checked	:= Array()
	var group_count 		:= 2*(tournament_round + 1)
	var team_selected		:int
	@warning_ignore("integer_division")
	var iterations			:= teams_array.size()/group_count
	for group_index in iterations:
		# Add teams fighting in the group
		teams_being_checked.clear()
		var i := group_count*group_index
		while i < group_count*(group_index + 1):
			if teams_playing[i]:
				teams_being_checked.append(i)
			i += 1
		
		if teams_being_checked.size() < 2:
			continue
		
		# Eliminate random teams (except for player's team)
		team_selected = -1
		if player_team in teams_being_checked:
			teams_being_checked.erase(player_team)
		team_selected = teams_being_checked.pick_random()
		
		teams_playing[team_selected] = false
		set_cross_visibility(team_selected, true)
		
	return

func _process(_delta):
#	if Input.is_anything_pressed():
#		if Input.is_action_pressed("move_down"):
#			camera.position.y += 5
#		if Input.is_action_pressed("move_up"):
#			camera.position.y -= 5
#		if Input.is_action_pressed("move_right"):
#			camera.position.x += 5
#		if Input.is_action_pressed("move_left"):
#			camera.position.x -= 5
#		if Input.is_action_just_pressed("action_accept"):
#			next_round()
#
#		clamp_camera_position_to_limits()
	pass

func clamp_camera_position_to_limits():
	var cam_pos 	= camera.position
	var cam_zoom	= camera.zoom
	
	camera.position.x = clamp(cam_pos.x, camera.limit_left + 360/cam_zoom.x, camera.limit_right - 360/cam_zoom.x)
	camera.position.y = clamp(camera.position.y, camera.limit_top + 288/cam_zoom.y, camera.limit_bottom - 288/cam_zoom.y)
