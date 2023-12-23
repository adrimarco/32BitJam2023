class_name TutorialMenu
extends Control

@onready var options_container 	:= $CanvasLayer/TutorialOptionsContainer
@onready var menu_canvas		:= $CanvasLayer
@onready var cursor				:=$CanvasLayer/CursorNode
@onready var tutorial_page		:= $CanvasLayer/TutorialPages
@onready var tutorialPages:Array = [$CanvasLayer/TutorialPages/ControlsPage, 
									$CanvasLayer/TutorialPages/TournamentPage, 
									$CanvasLayer/TutorialPages/CombatPage, 
									$CanvasLayer/TutorialPages/AbilitiesPage, 
									$CanvasLayer/TutorialPages/TerrainPage]

var labels				:Array
var options_count		:int
var selected_option 	:int
var input_enabled		:bool
var main_page			:bool = true
var tournament_node		:TournamentBoard
var credits_node		:CreditsMenu

var cursor_position		:= Vector2(465, 244)
var cursor_offset		:int = 44

signal exit_tutorial

func _ready():
	labels 			= options_container.get_children()
	options_count 	= labels.size()
	selected_option = 0
	input_enabled 	= true
	
	update_labels()

func _process(_delta):
	if Input.is_anything_pressed() and input_enabled:
		if Input.is_action_just_pressed("action_accept"):
			input_enabled = false
			execute_menu_action()
			AudioPlayerInstance.play_ui_sound_by_index(AudioPlayerInstance.UI_MAKE_SELECT)
		elif Input.is_action_just_pressed("action_back") and main_page:
			AudioPlayerInstance.play_ui_sound_by_index(AudioPlayerInstance.UI_UNDO_SELECT)
			exit_tutorial.emit()
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
	elif !input_enabled:
		process_input_page()

func update_labels():
	cursor.position = Vector2(cursor_position.x, cursor_position.y + cursor_offset*selected_option)	

func process_input_page():
	if Input.is_action_just_pressed("action_back"):
			tutorialPages[selected_option].hide()
			tutorial_page.hide()
			input_enabled = true
			AudioPlayerInstance.play_ui_sound_by_index(AudioPlayerInstance.UI_UNDO_SELECT)
			
func execute_menu_action():
	tutorial_page.show()
	for pIndex in tutorialPages.size():
		if selected_option == pIndex:
			tutorialPages[pIndex].show()
		else:
			tutorialPages[pIndex].hide()
#	if selected_option == 0:
#		hide_main_menu()
#		pass
#	elif selected_option == 1:
#		pass
#	elif selected_option == 2:
#		pass
#	elif selected_option == 3:
#		pass
#	elif selected_option == 4:
#		pass
#	else:
#		input_enabled = true
	

func hide_main_menu():
	menu_canvas.hide()
