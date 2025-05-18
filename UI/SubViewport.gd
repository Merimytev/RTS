extends SubViewport

@onready var camera = $Camera
var factoryBuilding = preload("res://UI/Minimap Sprites/FactorySprite.tscn")
var solarPanelBuilding = preload("res://UI/Minimap Sprites/SolarPanelSprite.tscn")
var builder = preload("res://UI/Minimap Sprites/BuilderSprite.tscn")
var soldier = preload("res://UI/Minimap Sprites/SoldierSprite.tscn")
var enemy = preload("res://UI/Minimap Sprites/EnemySprite.tscn")
var mineral = preload("res://UI/Minimap Sprites/MineralSprite.tscn")
var tree1 = preload("res://UI/Minimap Sprites/Tree1Sprite.tscn")
var tree2 = preload("res://UI/Minimap Sprites/Tree2Sprite.tscn")


func _ready() -> void:
	updateMap()
	
func updateMap():
	# Очистка старых узлов
	for i in range(get_child_count() - 3):
		get_child(i + 3).queue_free()
	for i in range(get_node("Units").get_child_count()):
		get_node("Units").get_child(i).queue_free()

	var MineralsPath = get_tree().get_root().get_node("World/NavigationRegion2D2/Objects")
	var TreesPath = get_tree().get_root().get_node("World/NavigationRegion2D2/NavigationRegion2D/Trees")
	var BuildingsPath = get_tree().get_root().get_node("World/NavigationRegion2D2/NavigationRegion2D/Buildings")
	var UnitsPath = get_tree().get_root().get_node("World/Units")

	for child in BuildingsPath.get_children():
		var sprite
		match child.name:
			"Factory", "Factory2":
				sprite = factoryBuilding.instantiate()
			"SolarPanel":
				sprite = solarPanelBuilding.instantiate()
			_:
				continue  # неизвестный объект
		sprite.position = child.position / 2
		add_child(sprite)

	for unit in UnitsPath.get_children():
		var sprite
		match unit.name:
			"Builder":
				sprite = builder.instantiate()
			"Soldier":
				sprite = soldier.instantiate()
			_:                             # всё остальное - враг
				sprite = enemy.instantiate()
		sprite.position = unit.position / 2
		get_node("Units").add_child(sprite)

	for child in TreesPath.get_children():
		var sprite
		match child.name:
			"Tree2":                      #  если в сцене дерево "Tree2"
				sprite = tree2.instantiate()
			_:                             # все остальные — Tree1
				sprite = tree1.instantiate()
		sprite.position = child.position / 2
		add_child(sprite)

	for child in MineralsPath.get_children():
		var sprite = mineral.instantiate()
		sprite.position = child.position / 2
		add_child(sprite)

func _process(_delta):
	var CameraPath = get_tree().get_root().get_node("World/Camera")
	var UnitsPath = get_tree().get_root().get_node("World/Units")
	camera.position = CameraPath.position / 2
	camera.zoom = CameraPath.zoom / 2
	
	var UnitsTotal = get_node("Units")
	var unit_count = min(UnitsPath.get_child_count(), UnitsTotal.get_child_count())
	for i in unit_count:
		var src = UnitsPath.get_child(i)
		var dst = UnitsTotal.get_child(i)
		if dst:
			dst.position = src.position / 2
