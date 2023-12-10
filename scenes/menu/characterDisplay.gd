class_name  CharacterDisplay
extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func initCharacterDisplay(ch:Character) -> void:
	#$CharacterName = ch.name
	$HPBar/TextHP.text = str(ch.hp) + "/20"
	$MPBar/TextMP.text = str(ch.mp) + "/20"

func updateValuesCharacterDisplay(ch:Character) -> void:
	
	$AttackTimerBar/TextureProgressBar.value = ch.attack_meter
	$HPBar/TextHP.text = str(ch.hp) + "/20"
	$MPBar/TextMP.text = str(ch.mp) + "/20"
