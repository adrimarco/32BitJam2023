extends Control


var cDisplay:PackedScene = preload("res://scenes/menu/characterDisplay.tscn")
var characterScene = preload("res://scenes/characters/Character.tscn")

var characterDisplays:Array[CharacterDisplay] =[]
var characterAttacking:bool = true
var characterRefAttacking:Character

const MAX_ABILITIES:int = 7
@onready var abilityTab = $ColorRect/AbilityTab
var abilityTabActive:bool = false
var abilitySelection:int = 0
var cursorAbilityPosition:Vector2 = Vector2(8, 40)
var characterAbilities = 3

# Menu selection variables
var selected:int 	= 0
var cursorPosition:Vector2 = Vector2(8, 40)
# Erase
var character:Character

# signals
signal characterMove(ch:Character)
signal characterAttack(ch:Character, ability:int)

# TODO: Add tiles class to exchange hability range to the battlefield and character movement
#signal characterMove(ch:Character, mov:Tiles)
#signal characterAttack(ch:Character, ability:Ability, range:Tiles)

# Called when the node enters the scene tree for the first time.
func _ready():
	character = characterScene.instantiate()
	characterRefAttacking = character
	character.hp = 99
	character.maxhp = 99
	character.mp = 20
	character.maxmp = 20
	character.spd = 10
	add_child(character)
	character.prepare_attack()
	var cDaux:CharacterDisplay = cDisplay.instantiate()
	cDaux.initCharacterDisplay(character)
	characterDisplays.append(cDaux)
	$ColorRect/MainActionMenu/Border/VBoxContainer.add_child(cDaux)
	
	# Connect battlefield signal
	# When a playable character is ready to attack -> emit signal
	#connect("character_attack_turn", Callable(self, "_storeCharacterAttacking"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Update UI data
	for display in characterDisplays:
		display.updateValuesCharacterDisplay(character)
		
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

func showAbilityMenu(visible:bool):
	$ColorRect/AbilityTab.visible = visible
	$ColorRect/MainActionMenu.visible = !visible
	abilityTabActive = visible

func _storeCharacterAttacking(ch:Character) -> void:
	characterAttacking = true
	characterRefAttacking = ch
