extends Node2D

@onready var Builder = preload("res://Units/Builder.tscn")
@onready var Soldier = preload("res://Units/Soldier.tscn")

@export var builder_energy: int = 50
@export var soldier_energy: int = 10
@export var soldier_cost: int = 12

var buildingPos = Vector2(300, 300)

func _on_create_pressed_builder() -> void:
	var randomPosX = randi_range(-100, 100)
	var randomPosY = randi_range(-100, 100)
	
	if Game.Energy >= builder_energy:
		var unitPath = get_tree().get_root().get_node("World/Units")
		var worldPath = get_tree().get_root().get_node("World")
		var MiniMapPath = get_tree().get_root().get_node("World/UI/MiniMap/SubViewportContainer/SubViewport")
		MiniMapPath._ready()
		
		var unit2 = Builder.instantiate()
	
		unit2.position = buildingPos + Vector2(randomPosX, randomPosY)
		unitPath.add_child(unit2)
		Game.Energy -= builder_energy  # Вычитаем стоимость
		worldPath.get_units()
	else:
		print("Недостаточно минералов для создания Builder. Требуется: ", builder_energy)

func _on_create_pressed_soldier() -> void:
	var randomPosX = randi_range(-100, 100)
	var randomPosY = randi_range(-100, 100)
	if Game.Minerals >= soldier_cost and Game.Energy >= soldier_energy:
		var unitPath = get_tree().get_root().get_node("World/Units")
		var worldPath = get_tree().get_root().get_node("World")
		var unit2 = Soldier.instantiate()
	
		unit2.position = buildingPos + Vector2(randomPosX, randomPosY)
		unitPath.add_child(unit2)
		Game.Minerals -= soldier_cost
		Game.Energy -= soldier_energy
		worldPath.get_units()
	else:
		print("Недостаточно минералов для создания Soldier. Требуется: ", soldier_cost)
		
func _on_close_pressed() -> void:
	var buildingPath = get_tree().get_root().get_node("World/Buildings")
	if buildingPath == null:
		push_error("Узел 'Buildings' не найден в дереве сцены!")
		queue_free()
		return
	
	for i in buildingPath.get_child_count():
		if buildingPath.get_child(i).Selected == true:
			buildingPath.get_child(i).Selected = false
	queue_free()
