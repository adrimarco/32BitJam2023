class_name CharacterSelector
extends Control

signal team_selected(characters_names:Array[int])
signal exit_character_selector

static var TEAM_SIZE				= 3

@onready var options_container		:= $CanvasLayer/OptionsContainer
@onready var character_viewer		:= $CanvasLayer/CharacterViewer
@onready var start_button			:= $CanvasLayer/StartButton
@onready var button_anim			:= $CanvasLayer/StartButton/AnimationPlayer

var option_scene			:= preload("res://scenes/menu/CharSelectorOption.tscn")

var characters_available	:Array[Character]
var characters_selected		:Array[int]
var focus_index				:int
var container_columns		:int

func _ready():
	for index in CharactersContainer.characters.size():
		var scene = CharactersContainer.characters[index]
		if not scene:
			continue
		
		var ch :Character = scene.instantiate()
		characters_available.append(ch)
		ch.hide()
		add_child(ch)
		
		create_banner(ch, characters_available.size()-1, index)
	
	focus_index = 0
	container_columns = options_container.columns
	update_focus()

func create_banner(ch:Character, index:int, value:int):
	if option_scene == null:
		return
	
	var new_banner := option_scene.instantiate()
	options_container.add_child(new_banner)
	
	# Configure option
	new_banner.set_character_name(ch.character_name)
	new_banner.set_option_index(index)
	new_banner.set_option_value(value)
	

func update_focus():
	for index in options_container.get_child_count():
		var selector_option := options_container.get_child(index)
		selector_option.set_selected(index in characters_selected)
		if focus_index == index and characters_selected.size() < TEAM_SIZE:
			selector_option.set_focus()
			character_viewer.set_character_to_display(characters_available[selector_option.option_index])
		
	update_start_button()

func update_start_button():
	if characters_selected.size() >= TEAM_SIZE:
		start_button.modulate = Color(1.0, 1.0, 1.0)
		button_anim.play("focus_start")
	else:
		start_button.modulate = Color(0.3, 0.3, 0.3)
		button_anim.stop()
	

func _process(_delta):
	if Input.is_anything_pressed():
		if Input.is_action_just_pressed("move_right"):
			select_next_horizontal()
		elif Input.is_action_just_pressed("move_left"):
			select_previous_horizontal()
		elif Input.is_action_just_pressed("move_up"):
			select_previous_vertical()
		elif Input.is_action_just_pressed("move_down"):
			select_next_vertical()
		elif Input.is_action_just_pressed("action_back"):
			if characters_selected.is_empty():
				exit_character_selector.emit()
			else:
				unselect_last_character()
		elif Input.is_action_just_pressed("action_accept"):
			if characters_selected.size() >= TEAM_SIZE:
				team_selection_finished()
			else:
				select_current_character()
		

func select_current_character():
	if focus_index < 0 or focus_index >= options_container.get_child_count():
		return
	
	var option_selected := options_container.get_child(focus_index)

	if not option_selected.option_index in characters_selected:
		characters_selected.append(option_selected.option_index)
		update_focus()

func unselect_last_character():
	if characters_selected.is_empty():
		return
	
	characters_selected.pop_back()
	update_focus()

func select_next_horizontal():
	if (focus_index+1) % container_columns == 0 or (focus_index + 1) >= characters_available.size():
		return
	
	focus_index += 1
	update_focus()

func select_previous_horizontal():
	if focus_index % container_columns == 0 or focus_index <= 0:
		return
	
	focus_index -= 1
	update_focus()

func select_next_vertical():
	if (focus_index + container_columns) >= characters_available.size():
		return
	
	focus_index += container_columns
	update_focus()

func select_previous_vertical():
	if focus_index - container_columns < 0:
		return
	
	focus_index -= container_columns
	update_focus()

func team_selection_finished():
	if characters_selected.is_empty():
		return
	
	var characters_index :Array[int] = []
	for ch_index in characters_selected:
		if ch_index >= 0 and ch_index < options_container.get_child_count():
			# Get the character from the list and save their index
			var option 	:= options_container.get_child(ch_index)
			characters_index.append(option.option_value)
		
	team_selected.emit(characters_index)
