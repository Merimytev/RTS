extends Node

@onready var spawn = preload("res://Global/spawn_unit.tscn")

var Minerals = 0
var Energy = 0

var database : SQLite

func reset_resources():
	Minerals = 0
	Energy = 0
	print("Ресурсы сброшены")

func spawnUnit(position):
	var path = get_tree().get_root().get_node("World/UI")
	var hasSpawn = false
	for i in path.get_child_count():
		if "SpawnUnit" in path.get_child(i).name:
			hasSpawn = true
	if hasSpawn == false:
		var spawnUnit = spawn.instantiate()
		spawnUnit.buildingPos = position
		path.add_child(spawnUnit)
