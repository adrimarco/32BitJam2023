class_name MainMenu
extends Control

signal player_selected_team(team:Array[int])

@onready var options_container 	:= $CanvasLayer/OptionsContainer
@onready var menu_canvas		:= $CanvasLayer
@onready var cursor				:=$CanvasLayer/CursorNode

var credits_scene 		:= preload("res://scenes/menu/creditsMenu.tscn")
var tournament_scene 	:= preload("res://scenes/menu/TournamentBoard.tscn")
var char_selector_scene	:= preload("res://scenes/menu/CharacterSelector.tscn")
var tutorial_scene 		:= preload("res://scenes/menu/tutorialMenu.tscn")

var labels				:Array
var options_count		:int
var selected_option 	:int
var input_enabled		:bool
var tournament_node		:TournamentBoard
var credits_node		:CreditsMenu
var tutorial_node		:TutorialMenu
var char_selector_node	:CharacterSelector

var cursor_position		:= Vector2(465, 244)
var cursor_offset		:int = 44


func _ready():
	labels 			= options_container.get_children()
	options_count 	= labels.size()
	selected_option = 0
	input_enabled 	= false
	
	update_labels()
	
	await StoryScreen.create_story_screen(self, 2)
	input_enabled = true
	AudioPlayerInstance.play_music_by_index(AudioPlayerInstance.MENU_MUSIC)

func _process(_delta):
	if Input.is_anything_pressed() and input_enabled:
		if Input.is_action_just_pressed("action_accept"):
			input_enabled = false
			execute_menu_action()
			AudioPlayerInstance.play_ui_sound_by_index(AudioPlayerInstance.UI_MAKE_SELECT)
		elif Input.is_action_just_pressed("move_down"):
			selected_option = (selected_option + 1) % options_count
			update_labels()
			AudioPlayerInstance.play_ui_sound_by_index(AudioPlayerInstance.UI_CHANGE_SELECT)
		elif Input.is_action_just_pressed("move_up"):
			selected_option -= 1
			if selected_option < 0:
				selected_option = options_count - 1
			update_labels()
			AudioPlayerInstance.play_ui_sound_by_index(AudioPlayerInstance.UI_CHANGE_SELECT)

func update_labels():
	cursor.position = Vector2(cursor_position.x, cursor_position.y + cursor_offset*selected_option)	

func execute_menu_action():
	if selected_option == 0:
		open_character_selector()
		hide_main_menu()
	elif selected_option == 1:
		load_tutorial_menu()
	elif selected_option == 2:
		load_credits()
	else:
		input_enabled = true
	

func open_character_selector():
	if char_selector_scene:
		char_selector_node = char_selector_scene.instantiate()
		char_selector_node.connect("team_selected", Callable(self, "load_game"))
		char_selector_node.connect("exit_character_selector", Callable(self, "close_character_selector"))
		get_tree().root.add_child(char_selector_node)

func close_character_selector():
	if char_selector_node:
		char_selector_node.queue_free()
		char_selector_node = null
	
	menu_canvas.show()
	input_enabled = true

func load_game(player_team:Array[int]):
	if char_selector_node:
		char_selector_node.queue_free()
		char_selector_node = null
	
	if tournament_scene:
		AudioPlayerInstance.stop_music(false)
		tournament_node = tournament_scene.instantiate()
		tournament_node.connect("activate_main_menu", Callable(self, "exit_tournament"))
		tournament_node.set_player_characters(player_team)
		get_tree().root.add_child(tournament_node)

func hide_main_menu():
	menu_canvas.hide()

func exit_tournament():
	if tournament_node:
		tournament_node.queue_free()
		tournament_node = null
	
	menu_canvas.show()
	input_enabled = true
	AudioPlayerInstance.play_music_by_index(AudioPlayerInstance.MENU_MUSIC)

func load_tutorial_menu():
	input_enabled = false
	if tutorial_scene:
		tutorial_node = tutorial_scene.instantiate()
		tutorial_node.connect("exit_tutorial", Callable(self, "exit_tutorial"))
		menu_canvas.add_child(tutorial_node)

func load_credits():
	input_enabled = false
	if credits_scene:
		credits_node = credits_scene.instantiate()
		credits_node.connect("exit_credits", Callable(self, "exit_credits"))
		menu_canvas.add_child(credits_node)


func exit_credits():
	if credits_node:
		credits_node.queue_free()
		credits_node = null
	
	input_enabled = true

func exit_tutorial():
	if tutorial_node:
		tutorial_node.queue_free()
		tutorial_node = null
	input_enabled = true
