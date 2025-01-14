extends Node2D

@onready var unit = preload("res://Unit/Unit.tscn")
var buildingPos = Vector2(300, 300)


func _on_create_pressed() -> void:
	var randomPosX = randi_range(-100, 100)
	var randomPosY = randi_range(-100, 100)
	
	var unitPath = get_tree().get_root().get_node("World/Units")
	var worldPath = get_tree().get_root().get_node("World")
	var unit1 = unit.instantiate()
	
	unit1.position = buildingPos + Vector2(randomPosX, randomPosY)
	unitPath.add_child(unit1)
	worldPath.get_units()

func _on_close_pressed() -> void:
	var buildingPath = get_tree().get_root().get_node("World/Buildings")
	for i in buildingPath.get_child_count():
		if buildingPath.get_child(i).Selected == true:
			buildingPath.get_child(i).Selected = false
	queue_free()
