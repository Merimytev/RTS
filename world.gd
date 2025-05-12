extends Node2D

var units = []
var total_elapsed_time = 0.0

func _process(delta: float) -> void:
	total_elapsed_time += delta
	# Обновление списка юнитов, чтобы удалить убитых
	update_units()

func _ready():
	get_units()

func get_units():
	units = get_tree().get_nodes_in_group("units")
	
func update_units():
	units = units.filter(func(unit): return is_instance_valid(unit))
	# Или заново получаем юниты из группы
	# units = get_tree().get_nodes_in_group("units")

func _on_area_selected(camera_node: Node, additive: bool) -> void:
	var start = camera_node.start
	var end = camera_node.end
	
	var area = []
	area.append(Vector2(min(start.x, end.x), min(start.y, end.y)))
	area.append(Vector2(max(start.x, end.x), max(start.y, end.y)))
	
	var ut = get_units_in_area(area)
	if not additive:
		for u in units:
			u.set_selected(false)
	for u in ut:
		u.set_selected(true)

		
func _on_single_click(click_position: Vector2, additive: bool):
	var area = []
	area.append(click_position - Vector2(30, 30)) # Левый верхний угол
	area.append(click_position + Vector2(25, 40)) # Правый нижний угол
	
	var units_in_click_area = get_units_in_area(area)

	if units_in_click_area.size() == 0:
		if not additive:
			for unit in units:
				unit.set_selected(false)
	else:
		if not additive:
			for unit in units:
				unit.set_selected(false)
		for unit in units_in_click_area:
			unit.set_selected(true)

func get_units_in_area(area):
	var u = []
	for unit in units:
		if unit.position.x > area[0].x and unit.position.x < area[1].x:
			if unit.position.y > area[0].y and unit.position.y < area[1].y:
				u.append(unit)
	return u

func get_elapsed_time() -> float:
	return total_elapsed_time
