class_name CharacterContainer
extends Node

static var BOSS_OFFSET	:= 100

var characters 			:Array
var bosses				:Array
var teams				:Array[Array]
var boss_teams			:Array[Array]
var teams_count			:int

func _ready():
	characters.append(load("res://scenes/characters/Knight.tscn"))
	characters.append(load("res://scenes/characters/Archer.tscn"))
	characters.append(load("res://scenes/characters/MalletMan.tscn"))
	characters.append(load("res://scenes/characters/Priestess.tscn"))
	characters.append(load("res://scenes/characters/Squeleton.tscn"))
	
	bosses.append(load("res://scenes/characters/King.tscn"))
	
	teams.append([2, 1, 1])
	teams.append([0, 1, 3])
	teams.append([4, 1, 3])
	teams_count = teams.size()
	
	boss_teams.append([BOSS_OFFSET])

func get_character_scene_by_id(id:int) -> PackedScene:
	if id >= BOSS_OFFSET:
		return get_boss_by_id(id - BOSS_OFFSET)
	
	if id < 0 or id >= characters.size():
		return null
	
	return characters[id]

func get_boss_by_id(id:int) -> PackedScene:
	if id < 0 or id >= bosses.size():
		return null
	
	return bosses[id]

func get_team_by_id(id:int) -> Array[int]:
	if id < 0 or id >= teams_count:
		return []
	
	var team :Array[int] = []
	team.append_array(teams[id])
	return team

func get_boss_team() -> Array[int]:
	var team :Array[int] = []
	team.append_array(boss_teams[0])
	return team
