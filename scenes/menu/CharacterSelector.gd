class_name CharacterSelector
extends Control

@onready var options_container		:= $CanvasLayer/OptionsContainer
@onready var character_viewer		:= $CanvasLayer/CharacterViewer

var option_scene			:= preload("res://scenes/menu/CharSelectorOption.tscn")

var characters_available	:Array[Character]
var characters_selected		:Array[Character]
var focus_index				:int
var container_columns		:int

func _ready():
	for scene in CharactersContainer.characters:
		if not scene:
			continue
		
		var ch :Character = scene.instantiate()
		characters_available.append(ch)
		ch.hide()
		add_child(ch)
		
		create_banner(ch, characters_available.size()-1)
	
	focus_index = 0
	container_columns = options_container.columns
	update_focus()

func create_banner(ch:Character, value:int):
	if option_scene == null:
		return
	
	var new_banner := option_scene.instantiate()
	options_container.add_child(new_banner)
	
	# Configure option
	new_banner.set_character_name(ch.character_name)
	new_banner.set_option_value(value)
	

func update_focus():
	for index in options_container.get_child_count():
		var selector_option := options_container.get_child(index)
		selector_option.set_selected(index in characters_selected)
		if focus_index == index:
			selector_option.set_focus()
			character_viewer.set_character_to_display(characters_available[selector_option.option_value])

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
	pass

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
