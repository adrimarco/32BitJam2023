class_name Character
extends Node2D

signal attack_ready(PackedScene)

# Constants
var METER_READY_VALUE	:float	= 2.0

# Class variables
var hp				:int	= 1
var mp				:int	= 1
var atk 			:int	= 1
var dfn 			:int	= 1
var spd 			:float	= 1
var attack_meter	:float	= 0.0
var preparing_attack:bool	= false


func _init(h, m, a, d, s):
	hp 	= h
	mp 	= m
	atk = a
	dfn = d
	spd = s
	attack_meter 		= 0.0
	preparing_attack 	= false

func _process(delta):
	if not preparing_attack:
		return
	
	# Charge attack
	attack_meter += delta * spd
	
	# Check if attack is ready to notify battlefield
	if attack_meter >= METER_READY_VALUE:
		attack_ready.emit(self)
	
	return

