extends Node

signal minerals_changed(new_value: int)

@onready var spawn = preload("res://Global/spawn_unit.tscn")

var Minerals = 0
var Energy = 0
var TimePlayed = 0.0

func reset_resources():
	Minerals = 0
	Energy = 0
	TimePlayed = 0.0
	print("Ресурсы и время сброшены")

var minerals_send: int:
	get:
		return Minerals
	set(value):
		Minerals = value
		minerals_changed.emit(value)

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
