class_name  CharacterDisplay
extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func initCharacterDisplay(ch:Character) -> void:
	$CharacterName.text = ch.character_name
	$HPBar/TextHP.text = str(ch.hp) + "/" + str(ch.maxhp)
	$MPBar/TextMP.text = str(ch.mp) + "/" + str(ch.maxmp)

func updateAttackMeter(ch:Character) -> void:
	$AttackTimerBar/TextureProgressBar.value = (ch.attack_meter / ch.ATTACK_READY_VALUE) * 100.0

func updateHealthValues(ch:Character) -> void:
	var hp:float = ch.hp
	var maxhp:float = ch.maxhp
	# Update UI values with character data
	$HPBar/TextHP.text = str(ch.hp) + "/" + str(ch.maxhp)
	$HPBar/TextureProgressBarHP.value = (hp / maxhp) * 100

func updateAbilityValues(ch:Character) -> void:
	var mp:float = ch.mp
	var maxmp:float = ch.maxmp
	# Update UI values with character data
	$MPBar/TextMP.text = str(ch.mp) + "/" + str(ch.maxmp)
	$MPBar/TextureProgressBarMP.value = (mp / maxmp) * 100
	
	
