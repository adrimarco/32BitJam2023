class_name Battlefield
extends Node3D

signal stop_preparing_attacks
signal resume_preparing_attacks

# Class variables
var characters 				:Array[Character]
var player_field			:Array[Array]
var enemy_field				:Array[Array]
var attack_cue				:Array[Character]
var character_attacking		:bool

func _init():
	character_attacking = false
	return
	
func _ready():
#	characters.append(Character.new(10, 10, 10, 10, 10))
#	characters.append(Character.new(100, 100, 100, 100, 100))	
#
#	characters_attack_cue.append(characters[0])
#	characters_attack_cue.append(characters[1])
#
#	print("Characters: " + str(characters[0].hp) + "  " + str(characters[1].hp))
#	print("Cue: " + str(characters_attack_cue[0].hp) + "  " + str(characters_attack_cue[1].hp))
#
#	characters[0].hp = 67
#	characters[1].hp = 92
#
#	print("Characters: " + str(characters[0].hp) + "  " + str(characters[1].hp))
#	print("Cue: " + str(characters_attack_cue[0].hp) + "  " + str(characters_attack_cue[1].hp))
	
	return
	
func _process(delta):
	return
	

func character_ready_to_attack(char:Character):
	if attack_cue.is_empty():
		attack_cue.append(char)
	else:
		# Add character ordered in cue
		var added = false
		for i in attack_cue.size():
			if char.attack_meter < attack_cue[i].attack_meter:
				attack_cue.insert(i, char)
				added = true
				break
			
		if not added:
			attack_cue.append(char)
		
	check_attack_cue()
	
	return


func check_attack_cue():
	if character_attacking:
		return
		
	if attack_cue.is_empty():
		# Attacks finished, resume attack charge
		resume_preparing_attacks.emit()
	else:
		# Get the character that has to attack
		character_attacking = true
		var attacking_character = attack_cue.back()
		
		attacking_character.reset_attack_meter()
		# attacking_character.attack.emit() !!!!!!!!
		attack_cue.pop_back()
	return


func attack_finished():
	character_attacking = false
	check_attack_cue()
	
	return
