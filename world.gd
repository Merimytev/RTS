extends Node2D

var units = []
var total_elapsed_time = 0.0

func _process(delta: float) -> void:
	total_elapsed_time += delta
	# Обновление списка юнитов, чтобы удалить убитых
	update_units()

func _ready():
	await get_tree().process_frame
	var win_panel = preload("res://UI/WinPanel.tscn").instantiate()
	add_child(win_panel)
	get_units()

func get_units():
	units = get_tree().get_nodes_in_group("units")
	
func update_units():
	units = units.filter(func(unit): return is_instance_valid(unit))


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

		
func _on_single_click(click_position: Vector2):
	var area = []
	area.append(click_position - Vector2(30, 30)) # Левый верхний угол
	area.append(click_position + Vector2(30, 50)) # Правый нижний угол
	
	var units_in_click_area = get_units_in_area(area)
	
	# Снимается выделение со всех юнитов
	if units_in_click_area.size() == 0:
		for unit in units:
			unit.set_selected(false)
	else:
		# Выделение одного юнита
		for unit in units:
			unit.set_selected(unit == units_in_click_area[0])

func get_units_in_area(area):
	var u = []
	for unit in units:
		if unit.position.x > area[0].x and unit.position.x < area[1].x:
			if unit.position.y > area[0].y and unit.position.y < area[1].y:
				u.append(unit)
	return u

func get_elapsed_time() -> float:
	return total_elapsed_time
