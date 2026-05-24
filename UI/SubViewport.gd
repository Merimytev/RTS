extends SubViewport



var map_scale := 0.05
var canvas: Node2D
var vp_size := Vector2(280, 280)  # ← хранить размер здесь

var buildings_container: Node
var trees_container: Node
var minerals_container: Node

var static_objects: Array = []
var dynamic_objects: Array = []
var world_offset := Vector2.ZERO

func _ready():
	
	render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	render_target_update_mode = SubViewport.UPDATE_ALWAYS
	buildings_container = get_node_or_null("/root/World/NavigationRegion2D2/NavigationRegion2D/Buildings")
	trees_container     = get_node_or_null("/root/World/NavigationRegion2D2/NavigationRegion2D/Trees")
	minerals_container  = get_node_or_null("/root/World/NavigationRegion2D2/Objects")
	var cam = get_node_or_null("Camera")
	if cam:
		cam.queue_free()
	# ← Берём реальный размер SubViewport здесь
	vp_size = Vector2(get_size())
	

	

	canvas = Node2D.new()
	canvas.name = "MinimapCanvas"
	canvas.position = Vector2.ZERO
	add_child(canvas)
	canvas.draw.connect(_on_canvas_draw)

	if buildings_container:
		buildings_container.child_entered_tree.connect(func(_n): call_deferred("collect_static_objects"))
		buildings_container.child_exiting_tree.connect(func(_n): call_deferred("collect_static_objects"))
	if trees_container:
		trees_container.child_entered_tree.connect(func(_n): call_deferred("collect_static_objects"))
		trees_container.child_exiting_tree.connect(func(_n): call_deferred("collect_static_objects"))
	if minerals_container:
		minerals_container.child_entered_tree.connect(func(_n): call_deferred("collect_static_objects"))
		minerals_container.child_exiting_tree.connect(func(_n): call_deferred("collect_static_objects"))

	await get_tree().process_frame
	vp_size = Vector2(get_size())  # ← обновляем после кадра на случай если не успел
	collect_static_objects()

func collect_static_objects() -> void:
	static_objects.clear()

	if buildings_container:
		for b in buildings_container.get_children():
			if is_instance_valid(b) and b is Node2D:
				static_objects.append({"node": b, "color": Color(0.3, 0.5, 1.0), "size": Vector2(6, 6)})
				# Подписываемся на удаление каждого объекта
				if not b.tree_exiting.is_connected(_on_object_removed):
					b.tree_exiting.connect(_on_object_removed)

	if trees_container:
		for t in trees_container.get_children():
			if is_instance_valid(t) and t is Node2D:
				static_objects.append({"node": t, "color": Color(0.2, 0.55, 0.2), "size": Vector2(3, 3)})
				if not t.tree_exiting.is_connected(_on_object_removed):
					t.tree_exiting.connect(_on_object_removed)

	if minerals_container:
		for m in minerals_container.get_children():
			if is_instance_valid(m) and m is Node2D:
				static_objects.append({"node": m, "color": Color(1.0, 0.85, 0.1), "size": Vector2(4, 4)})
				# ← каждый минерал сам сообщит когда исчезнет
				if not m.tree_exiting.is_connected(_on_object_removed):
					m.tree_exiting.connect(_on_object_removed)

	_recalculate_offset()
	

func _on_object_removed() -> void:
	# Чистим невалидные объекты сразу
	static_objects = static_objects.filter(func(o): return is_instance_valid(o["node"]))

func _recalculate_offset() -> void:
	if static_objects.is_empty():
		world_offset = Vector2.ZERO
		return

	var min_pos := Vector2(INF, INF)
	var max_pos := Vector2(-INF, -INF)

	for obj in static_objects:
		var p: Vector2 = (obj["node"] as Node2D).global_position
		min_pos = min_pos.min(p)
		max_pos = max_pos.max(p)

	var world_size = max_pos - min_pos
	var padding = 20.0
	var scale_x = (vp_size.x - padding * 2) / max(world_size.x, 1)
	var scale_y = (vp_size.y - padding * 2) / max(world_size.y, 1)
	map_scale = min(scale_x, scale_y)

	var world_center = (min_pos + max_pos) * 0.5
	world_offset = vp_size * 0.5 - world_center * map_scale

	

func _on_canvas_draw() -> void:
	canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	
	canvas.draw_rect(Rect2(Vector2.ZERO, vp_size), Color(0.08, 0.08, 0.08, 0.9))
	canvas.draw_rect(Rect2(Vector2.ZERO, vp_size), Color(0.4, 0.4, 0.4), false, 1.5)

	for obj in static_objects:
		var node = obj["node"]
		if not is_instance_valid(node):
			continue
		var pos: Vector2 = (node as Node2D).global_position * map_scale + world_offset
		var sz: Vector2 = obj["size"]
		if pos.x < 0 or pos.y < 0 or pos.x > vp_size.x or pos.y > vp_size.y:
			continue
		canvas.draw_rect(Rect2(pos - sz * 0.5, sz), obj["color"])

	for obj in dynamic_objects:
		var node = obj["node"]
		if not is_instance_valid(node):
			continue           
		var pos: Vector2 = (node as Node2D).global_position * map_scale + world_offset
		if pos.x < 0 or pos.y < 0 or pos.x > vp_size.x or pos.y > vp_size.y:
			continue           
		canvas.draw_circle(pos, obj["radius"], obj["color"])           

func _process(_delta: float) -> void:
	static_objects = static_objects.filter(func(o): return is_instance_valid(o["node"]))
	dynamic_objects = dynamic_objects.filter(func(o): return is_instance_valid(o["node"]))
	canvas.queue_redraw()

func register_unit(node: Node, color: Color, radius: float = 3.0) -> void:
	if not dynamic_objects.any(func(o): return o["node"] == node):
		dynamic_objects.append({"node": node, "color": color, "radius": radius})

func unregister_unit(node: Node) -> void:
	dynamic_objects = dynamic_objects.filter(func(o): return o["node"] != node)
