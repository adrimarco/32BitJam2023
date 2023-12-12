class_name ActionMenu

extends Control

var cDisplay:PackedScene = preload("res://scenes/menu/characterDisplay.tscn")
var characterScene = preload("res://scenes/characters/Character.tscn")

var playerCharacters:Array = []
var characterDisplays:Array[CharacterDisplay] =[]
var characterAttacking:bool = false
var characterRefAttacking:Character
@onready var characterList = $ColorRect/MainActionMenu/Border/VBoxContainer

const MAX_ABILITIES:int = 7
@onready var abilityTab = $ColorRect/AbilityTab
var abilityTabActive:bool = false
var abilitySelection:int = 0
var cursorAbilityPosition:Vector2 = Vector2(8, 40)
var characterAbilities = 3

# Menu selection variables
var selected:int 	= 0
var cursorPosition:Vector2 = Vector2(8, 40)

# signals
signal characterMove(ch:Character)
signal characterAttack(ch:Character, ability:int)

# TODO: Add tiles class to exchange hability range to the battlefield and character movement
#signal characterMove(ch:Character, mov:Tiles)
#signal characterAttack(ch:Character, ability:Ability, range:Tiles)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	

func initCharacterList():
	var cDaux:CharacterDisplay = cDisplay.instantiate()
	playerCharacters = get_parent().getCharactersFromBattleField(true)
	clearCharacterDisplays()
	
	for ch in playerCharacters:
		cDaux.initCharacterDisplay(ch)
		characterDisplays.append(cDaux)
		characterList.add_child(cDaux)
		
	for index in range(characterDisplays.size()):
		characterDisplays[index].updateHealthValues(playerCharacters[index])
		characterDisplays[index].updateAbilityValues(playerCharacters[index])
		
func clearCharacterDisplays():
	for ch in characterDisplays:
		ch.queue_free()
	characterDisplays.clear()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Update UI data
	for index in range(characterDisplays.size()):
		characterDisplays[index].updateAttackMeter(playerCharacters[index])

	# input
	if characterRefAttacking != null && characterAttacking:
		# Move cursor
		if !abilityTabActive:
			if Input.is_action_just_pressed("move_down"):
				selected = (selected + 1) % 3
			if Input.is_action_just_pressed("move_up"):
				selected = (selected - 1) % 3
				if selected < 0:
					selected += 3
			$ColorRect/MainActionMenu/Border2/fightOptionsMenu/CursorNode.position = Vector2(cursorPosition.x, cursorPosition.y + 24*selected)
		else:
			pass
		# Option selected
		if Input.is_action_just_pressed("action_accept"):
			optionSelected(abilityTabActive)
		
		if Input.is_action_just_pressed("action_back") && abilityTabActive:
			showAbilityMenu(false)


func optionSelected(isAbilityMenu):
	if   selected == 0:
		characterMove.emit(characterRefAttacking)
	elif selected == 1:
		pass
	elif selected == 2:
		showAbilityMenu(true)

func printCharacterAbilities(ch:Character):
	# TODO: Get all abilities name and create a rich text node
	# Store abilities count in characterAbilities
	pass

#func printCharacterAbilityDescription(ab:Ability):
#	pass

func showAbilityMenu(_visible:bool):
	$ColorRect/AbilityTab.visible = _visible
	$ColorRect/MainActionMenu.visible = !_visible
	abilityTabActive = _visible

func _storeCharacterAttacking(ch:Character) -> void:
	characterAttacking = true
	characterRefAttacking = ch
