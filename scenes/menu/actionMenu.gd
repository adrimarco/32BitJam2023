class_name ActionMenu

extends Control

static var NORMAL_COLOR			:Color = Color(1.0, 1.0, 1.0)
static var DEAD_COLOR			:Color = Color(0.3, 0.3, 0.3)
static var TURNBAR_NORMAL_COLOR :Color = Color(1.0, 1.0, 1.0)
static var TURNBAR_FULL_COLOR 	:Color = Color(0.97, 0.51, 0.79)
static var ABILITY_BLOCK_COLOR  :Color = Color(0.2, 0.2, 0.2)

var cDisplay:PackedScene = preload("res://scenes/menu/characterDisplay.tscn")
var characterScene = preload("res://scenes/characters/Character.tscn")

var playerCharacters:Array = []
var characterDisplays:Array[CharacterDisplay] =[]
var characterAttacking:bool = false
var characterRefAttacking:Character
@onready var characterList = $ColorRect/MainActionMenu/Border/VBoxContainer

# Menu selection variables
var selected:int 	= 0
var cursorPosition:Vector2 = Vector2(150, 16)
var cursorPositionOffset:int = 36
var fightOptionsCount:int = 4
@onready var actionInfoText 	= $actionInfoText
@onready var cursorActionMenu 	= $ColorRect/MainActionMenu/Border2/fightOptionsMenu/CursorNode
@onready var cursorAbilityMenu 	= $ColorRect/AbilityTab/CursorNode
@onready var fightOptionsMenu 	= $ColorRect/MainActionMenu/Border2/fightOptionsMenu
@onready var movementOption 	= $ColorRect/MainActionMenu/Border2/fightOptionsMenu/VBoxContainer/OptionBorder

@onready var abilityDescText 	= $ColorRect/AbilityTab/AbilityDescBorder/AbilityDesc
@onready var abilityPowerValue 	= $ColorRect/AbilityTab/AbilityDescBorder/AbilityPowerBorder/AbilityPowerValue
@onready var abilityPMValue 	= $ColorRect/AbilityTab/AbilityDescBorder/AbilityPMBorder/AbilityPMValue
@onready var abilityTab 		= $ColorRect/AbilityTab
@onready var abilityNameList 	= $ColorRect/AbilityTab/AbilityNameBorder/AbilityNameList
var optionBox = preload("res://scenes/menu/menuOptionBox.tscn")

#const MAX_ABILITIES:int = 7
var characterAbilitiesCount:int = 0
var characterAbilitiesTextOffset:int = 30

var abilityTabActive:bool = false
var abilitySelection:int = 0
var cursorAbilityPosition:Vector2 = Vector2(229, 41)


var input_enabled:bool = false

var resetTimerBarColor:bool = true
# signals
signal characterMove(ch:Character)
signal characterAttack(ch:Character)
signal characterRest
signal characterAbility(ch:Character, abl:Ability)
signal requestAbilityRange(ch:Character, abl:Ability)
signal requestUnmarkRange

# Called when the node enters the scene tree for the first time.
func _ready():
	changeNodeVisibility(fightOptionsMenu, false)
	

func initCharacterList():
	playerCharacters = get_parent().get_parent().get_parent().getCharactersFromBattleField(true)
	clearCharacterDisplays()
	
	for ch in playerCharacters:
		var cDaux:CharacterDisplay = cDisplay.instantiate()
		cDaux.initCharacterDisplay(ch)
		characterDisplays.append(cDaux)
		characterList.add_child(cDaux)
		ch.connect("health_changed", Callable(cDaux, "updateHealthValues"))
		ch.connect("energy_changed", Callable(cDaux, "updateAbilityValues"))
		
	for index in range(characterDisplays.size()):
		characterDisplays[index].modulate = NORMAL_COLOR
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
		if resetTimerBarColor && !characterRefAttacking:
			hide_action_info_text()
			characterDisplays[index].changeModulateColor(TURNBAR_NORMAL_COLOR)
			resetTimerBarColor = false
		if characterRefAttacking != playerCharacters[index]:
			characterDisplays[index].updateAttackMeter(playerCharacters[index])
	
	# input
	if not input_enabled or not Input.is_anything_pressed():
		return 
	
	if characterRefAttacking != null && characterAttacking:
		# Move cursor
		if !abilityTabActive:
			if Input.is_action_just_pressed("move_down"):
				selected = (selected + 1) % fightOptionsCount
				AudioPlayerInstance.play_ui_sound_by_index(AudioPlayerInstance.UI_CHANGE_SELECT)
			elif Input.is_action_just_pressed("move_up"):
				AudioPlayerInstance.play_ui_sound_by_index(AudioPlayerInstance.UI_CHANGE_SELECT)
				selected = (selected - 1) % fightOptionsCount
				if selected < 0:
					selected += fightOptionsCount
			cursorActionMenu.position = Vector2(cursorPosition.x, cursorPosition.y + cursorPositionOffset*selected)
			# Option selected
			if Input.is_action_just_pressed("action_accept"):
				AudioPlayerInstance.play_ui_sound_by_index(AudioPlayerInstance.UI_MAKE_SELECT)
				optionSelected()
		else:
			checkAbilityTabInput()
		

func checkAbilityTabInput():
	if Input.is_action_just_pressed("move_down"):
		abilitySelection = (abilitySelection + 1) % characterAbilitiesCount
		hoverAbility()
		AudioPlayerInstance.play_ui_sound_by_index(AudioPlayerInstance.UI_CHANGE_SELECT)
	elif Input.is_action_just_pressed("move_up"):
		abilitySelection = (abilitySelection - 1) % characterAbilitiesCount
		if abilitySelection < 0:
			abilitySelection += characterAbilitiesCount
		hoverAbility()
		AudioPlayerInstance.play_ui_sound_by_index(AudioPlayerInstance.UI_CHANGE_SELECT)
	elif Input.is_action_just_pressed("action_back"):
			showAbilityMenu(false)
			requestUnmarkRange.emit()
			AudioPlayerInstance.play_ui_sound_by_index(AudioPlayerInstance.UI_UNDO_SELECT)
	elif Input.is_action_just_pressed("action_accept"):
		AudioPlayerInstance.play_ui_sound_by_index(AudioPlayerInstance.UI_MAKE_SELECT)
		disable_input()
		show_action_info_text(getAbilityFromIndex(characterRefAttacking, abilitySelection))
		characterAbility.emit(characterRefAttacking, getAbilityFromIndex(characterRefAttacking, abilitySelection))

func hideActionMenu():
	changeNodeVisibility(fightOptionsMenu, false)

func hoverAbility():
	hide_action_info_text()
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
		show_action_info_text(null)
		characterMove.emit(characterRefAttacking)
	elif selected == 1:
		disable_input()
		show_action_info_text(characterRefAttacking.basic_attack)
		characterAttack.emit(characterRefAttacking)
	elif selected == 2:
		showAbilityMenu(true)
		check_abilities_cost()
		hoverAbility()
	elif selected == 3:
		characterRest.emit()
		

func show_action_info_text(ab:Ability):
	if !ab:
		actionInfoText.set_text_info(actionInfoText.InfoActionIndex.SELECT_TARGET)
	elif ab.target_type == Ability.TargetTypes.Selection:
		actionInfoText.set_text_info(actionInfoText.InfoActionIndex.SELECT_TARGET)
	else:
		actionInfoText.set_text_info(actionInfoText.InfoActionIndex.CONFIRM_ACTION)
	actionInfoText.show()

func hide_action_info_text():
	actionInfoText.hide()

func printcharacterAbilities(ch:Character) -> void:
	# Store abilities count in characterAbilitiesCount
	characterAbilitiesCount = ch.abilities.size()
	
	clearAbilityList()
	
	# Get all abilities name and create a rich text node
	for cAb in ch.abilities:
		var opBox = optionBox.instantiate()
		opBox.get_node("OptionText").text = cAb.ability_name
		opBox.custom_minimum_size = Vector2(90, 11)
		abilityNameList.add_child(opBox)
		

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
	abilityPowerValue.text = str(ab.dmg_multiplier*100)
	abilityPMValue.text = str(characterRefAttacking.get_ability_cost_from_character(ab))

func showAbilityMenu(newVisibility:bool):
	$ColorRect/AbilityTab.visible = newVisibility
	$ColorRect/MainActionMenu.visible = not newVisibility
	abilityTabActive = newVisibility
	changeNodeVisibility(fightOptionsMenu, not newVisibility)

func check_abilities_cost():
	for cAbIndex in characterRefAttacking.abilities.size():
		if characterRefAttacking.get_ability_cost_from_character(characterRefAttacking.abilities[cAbIndex]) > characterRefAttacking.mp:
			abilityNameList.get_child(cAbIndex).modulate = ABILITY_BLOCK_COLOR
		else:
			abilityNameList.get_child(cAbIndex).modulate = NORMAL_COLOR

func _storeCharacterAttacking(ch:Character) -> void:
	resetTimerBarColor = true
	characterAttacking = true
	characterRefAttacking = ch
	abilitySelection = 0
	var chDisplay:CharacterDisplay = getCharacterDisplayFromCharacter(ch)
	if chDisplay:
		chDisplay.clearAttackMeter(100)
		chDisplay.changeModulateColor(TURNBAR_FULL_COLOR)
	printcharacterAbilities(characterRefAttacking)
	printCharacterAbilityDescription(getAbilityFromIndex(characterRefAttacking, abilitySelection))
	
	if ch.has_effects([AbilityEffect.EffectType.Stun]):
		movementOption.modulate = ABILITY_BLOCK_COLOR
	else:
		movementOption.modulate = NORMAL_COLOR
		
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

func characterDead(ch:Character):
	var chIndex:int = -1
	# Search character
	for chI in playerCharacters.size():
		if playerCharacters[chI] == ch:
			chIndex = chI
			break
	
	if chIndex == -1:
		return
	
	var chDisplay = characterDisplays[chIndex]
	
	# Change character display color
	chDisplay.modulate = DEAD_COLOR
	
	# hp and mp = 0
	chDisplay.updateHealthValues(0)
	chDisplay.updateAbilityValues(0)
	chDisplay.clearAttackMeter(0)
	
	# remove from characterDisplay array
	characterDisplays.remove_at(chIndex)
	playerCharacters.remove_at(chIndex)

func getCharacterDisplayFromCharacter(ch:Character) -> CharacterDisplay:
	for i in playerCharacters.size():
		if playerCharacters[i] == ch:
			return characterDisplays[i]
	return null
	
func resumePreparingAttacks():
	for chD in characterDisplays:
		chD.changeModulateColor(TURNBAR_NORMAL_COLOR)
	characterRefAttacking = null
