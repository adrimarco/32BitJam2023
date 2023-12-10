extends Control


var cDisplay:PackedScene = preload("res://scenes/menu/characterDisplay.tscn")
var characterDisplays:Array[CharacterDisplay] =[]
var character = Character.new(99, 10, 6, 6, 10)

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(character)
	character.prepare_attack()
	var cDaux:CharacterDisplay = cDisplay.instantiate()
	cDaux.initCharacterDisplay(character)
	characterDisplays.append(cDaux)
	$ColorRect/HBoxContainer/Border/VBoxContainer.add_child(cDaux)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for display in characterDisplays:
		display.updateValuesCharacterDisplay(character)
