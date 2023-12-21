class_name CreditsMenu
extends Control
@onready var external_title = $NinePatchRect/EATitle
@onready var pages:Array  	= [$FirstPage, $SecondPage, $ThirdPage]
@onready var cursor_left  	= $NinePatchRect/CursorNodeLeft
@onready var cursor_right 	= $NinePatchRect/CursorNodeRight
var current_page = 0

signal exit_credits

func _ready():
	cursor_left.get_node("AnimationPlayer").play("cursor_idle")
	cursor_right.get_node("AnimationPlayer").play("cursor_idle")
	show_page()

func _process(_delta):
	if Input.is_action_just_pressed("move_left"):
		if current_page > 0:
			current_page -= 1
		show_page()
	elif Input.is_action_just_pressed("move_right"):
		if current_page < pages.size()-1:
			current_page += 1
		show_page()
	elif Input.is_action_just_pressed("action_back"):
		exit_credits.emit()
	
	if current_page != 0:
		external_title.show()
		cursor_left.show()
		cursor_right.show()
		if current_page == pages.size()-1:
			cursor_right.hide()
	else:
		cursor_left.hide()
		cursor_right.show()
		external_title.hide()
	
func show_page():
	for pIndex in pages.size():
		if pIndex == current_page:
			pages[pIndex].show()
		else:
			pages[pIndex].hide()
