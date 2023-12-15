class_name ActionMenu

extends Control

var cDisplay:PackedScene = preload("res://scenes/menu/characterDisplay.tscn")
var characterScene = preload("res://scenes/characters/Character.tscn")

var playerCharacters:Array = []
var characterDisplays:Array[CharacterDisplay] =[]
var characterAttacking:bool = false
var characterRefAttacking:Character
@onready var characterList = $ColorRect/MainActionMenu/Border/VBoxContainer

# Menu selection variables
var selected:int 	= 0
var cursorPosition:Vector2 = Vector2(8, 40)
@onready var cursorActionMenu = $ColorRect/MainActionMenu/Border2/fightOptionsMenu/CursorNode
@onready var cursorAbilityMenu = $ColorRect/AbilityTab/CursorNode
@onready var fightOptionsMenu = $ColorRect/MainActionMenu/Border2/fightOptionsMenu

@onready var abilityDescText = $ColorRect/AbilityTab/AbilityDescBorder/AbilityDesc
@onready var abilityTab = $ColorRect/AbilityTab
@onready var abilityNameList = $ColorRect/AbilityTab/AbilityNameBorder/AbilityNameList
const MAX_ABILITIES:int = 7
var characterAbilitiesCount:int = 0
var characterAbilitiesTextOffset:int = 16

var abilityTabActive:bool = false
var abilitySelection:int = 0
var cursorAbilityPosition:Vector2 = Vector2(20, 36)

var input_enabled:bool = false

# signals
signal characterMove(ch:Character)
signal characterAttack(ch:Character)
signal characterAbility(ch:Character, abl:Ability)
signal requestAbilityRange(ch:Character, abl:Ability)
signal requestUnmarkRange

# Called when the node enters the scene tree for the first time.
func _ready():
	changeNodeVisibility(fightOptionsMenu, false)
	

func initCharacterList():
	playerCharacters = get_parent().getCharactersFromBattleField(true)
	clearCharacterDisplays()
	
	for ch in playerCharacters:
		var cDaux:CharacterDisplay = cDisplay.instantiate()
		cDaux.initCharacterDisplay(ch)
		characterDisplays.append(cDaux)
		characterList.add_child(cDaux)
		ch.connect("health_changed", Callable(cDaux, "updateHealthValues"))
		ch.connect("energy_changed", Callable(cDaux, "updateAbilityValues"))
		
	for index in range(characterDisplays.size()):
		characterDisplays[index].updateHealthValues(playerCharacters[index].hp)
		characterDisplays[index].updateAbilityValues(playerCharacters[index].mp)
		
func clearCharacterDisplays():
	for ch in characterDisplays:
		ch.queue_free()
	characterDisplays.clear()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# Update UI data
	for index in range(characterDisplays.size()):
		characterDisplays[index].updateAttackMeter(playerCharacters[index])
	
	# input
	if not input_enabled or not Input.is_anything_pressed():
		return 
	
	if characterRefAttacking != null && characterAttacking:
		# Move cursor
		if !abilityTabActive:
			if Input.is_action_just_pressed("move_down"):
				selected = (selected + 1) % 3
			elif Input.is_action_just_pressed("move_up"):
				selected = (selected - 1) % 3
				if selected < 0:
					selected += 3
			cursorActionMenu.position = Vector2(cursorPosition.x, cursorPosition.y + 24*selected)
			# Option selected
			if Input.is_action_just_pressed("action_accept"):
				optionSelected()
		else:
			checkAbilityTabInput()
		

func checkAbilityTabInput():
	if Input.is_action_just_pressed("move_down"):
		abilitySelection = (abilitySelection + 1) % characterAbilitiesCount
		hoverAbility()
	elif Input.is_action_just_pressed("move_up"):
		abilitySelection = (abilitySelection - 1) % characterAbilitiesCount
		if abilitySelection < 0:
			abilitySelection += characterAbilitiesCount
		hoverAbility()
	elif Input.is_action_just_pressed("action_back"):
			showAbilityMenu(false)
			requestUnmarkRange.emit()
	elif Input.is_action_just_pressed("action_accept"):
		disable_input()
		characterAbility.emit(characterRefAttacking, getAbilityFromIndex(characterRefAttacking, abilitySelection))
	

func hideActionMenu():
	changeNodeVisibility(fightOptionsMenu, false)

func hoverAbility():
	if not abilityTabActive:
		return
	
	# Update cursor position
	cursorAbilityMenu.position = Vector2(cursorAbilityPosition.x, cursorAbilityPosition.y + characterAbilitiesTextOffset*abilitySelection)
	
	# Show ability info
	var selectedAbility: Ability = getAbilityFromIndex(characterRefAttacking, abilitySelection)
	printCharacterAbilityDescription(selectedAbility)
	
	# Show ability range
	requestAbilityRange.emit(characterRefAttacking, selectedAbility)

func optionSelected():
	if   selected == 0:
		disable_input()
		characterMove.emit(characterRefAttacking)
	elif selected == 1:
		disable_input()
		characterAttack.emit(characterRefAttacking)
	elif selected == 2:
		showAbilityMenu(true)
		hoverAbility()
		

func printcharacterAbilities(ch:Character) -> void:
	# Store abilities count in characterAbilitiesCount
	characterAbilitiesCount = ch.abilities.size()
	
	clearAbilityList()
	
	# Get all abilities name and create a rich text node
	for cAb in ch.abilities:
		var label:RichTextLabel = RichTextLabel.new()
		label.text = cAb.ability_name
		label.custom_minimum_size = Vector2(0, 12)
		label.scroll_active = false
		label.theme = preload("res://resources/menuTheme.tres")
		abilityNameList.add_child(label)
		

func clearAbilityList():
	for child in abilityNameList.get_children():
		child.queue_free()
	

func getAbilityFromIndex(ch:Character, index:int) ->Ability:
	for cAbIndex in ch.abilities.size():
		if cAbIndex == index:
			return ch.abilities[cAbIndex]
	return null

func printCharacterAbilityDescription(ab:Ability):
	abilityDescText.text = ab.description

func showAbilityMenu(newVisibility:bool):
	$ColorRect/AbilityTab.visible = newVisibility
	$ColorRect/MainActionMenu.visible = not newVisibility
	abilityTabActive = newVisibility
	changeNodeVisibility(fightOptionsMenu, not newVisibility)

func _storeCharacterAttacking(ch:Character) -> void:
	characterAttacking = true
	characterRefAttacking = ch
	abilitySelection = 0
	printcharacterAbilities(characterRefAttacking)
	printCharacterAbilityDescription(getAbilityFromIndex(characterRefAttacking, abilitySelection))
	
	set_input_enabled()
	showAbilityMenu(false)

func changeNodeVisibility(node:Node, isVisible:bool):
	node.visible = isVisible

func set_input_enabled():
	input_enabled = true
	changeNodeVisibility(cursorActionMenu, true)

func disable_input():
	input_enabled = false
	changeNodeVisibility(cursorActionMenu, false)
