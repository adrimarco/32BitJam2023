class_name MainMenu
extends Control

@onready var options_container 	:= $CanvasLayer/OptionsContainer
@onready var menu_canvas		:= $CanvasLayer

var labels				:Array
var options_count		:int
var selected_option 	:int
var input_enabled		:bool
var tournament_node		:TournamentBoard

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
		elif Input.is_action_just_pressed("move_down"):
			selected_option = (selected_option + 1) % options_count
			update_labels()
		elif Input.is_action_just_pressed("move_up"):
			selected_option -= 1
			if selected_option < 0:
				selected_option = options_count - 1
			update_labels()

func update_labels():
	for i in labels.size():
		if i == selected_option:
			labels[i].modulate = Color(0.0, 0.0, 1.0)
		else:
			labels[i].modulate = Color(1.0, 1.0, 1.0)			

func execute_menu_action():
	if selected_option == 0:
		load_game()
		hide_main_menu()
	elif selected_option == 1:
		load_tutorial_menu()
	elif selected_option == 2:
		load_credits()
	else:
		input_enabled = true
	

func load_game():
	var tournament_scene := load("res://scenes/menu/TournamentBoard.tscn")
	
	if tournament_scene:
		tournament_node = tournament_scene.instantiate()
		tournament_node.connect("activate_main_menu", Callable(self, "exit_tournament"))
		get_tree().root.add_child(tournament_node)

func hide_main_menu():
	menu_canvas.hide()

func exit_tournament():
	if tournament_node:
		tournament_node.queue_free()
		tournament_node = null
	
	menu_canvas.show()
	input_enabled = true

func load_tutorial_menu():
	input_enabled = true
	pass

func load_credits():
	input_enabled = true
	pass