class_name  CharacterDisplay
extends Control

var maxHp :float
var maxMp :float

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
	maxHp = ch.maxhp
	maxMp = ch.maxmp

func updateAttackMeter(ch:Character) -> void:
	$AttackTimerBar/TextureProgressBar.value = (ch.attack_meter / ch.ATTACK_READY_VALUE) * 100.0

func updateHealthValues(hp:int) -> void:
	var hpf:float = hp
	# Update UI values with character data
	$HPBar/TextHP.text = str(hpf) + "/" + str(maxHp)
	$HPBar/TextureProgressBarHP.value = (hpf / maxHp) * 100

func updateAbilityValues(mp:int) -> void:
	var mpf:float = mp
	# Update UI values with character data
	$MPBar/TextMP.text = str(mpf) + "/" + str(maxMp)
	$MPBar/TextureProgressBarMP.value = (mpf / maxMp) * 100


func clearAttackMeter():
	$AttackTimerBar/TextureProgressBar.value = 0
