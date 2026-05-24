extends CharacterBody2D

@export var selected = false
@onready var box = get_node("Box")
@onready var Builder = get_node("Builder")
@onready var navigation_agent = $NavigationAgent2D
@onready var health_bar = $Healthbar
var Speed = 80
var HP = 60
var max_HP = 60
var target_queue = []
var is_moving := false

var target_mineral: Node = null
var current_mineral: Node = null
var is_mining := false
@export var build_panel_scene: PackedScene
@export var build_preview_scene: PackedScene
var build_panel_instance: Node = null

func _ready():
	set_selected(selected)
	add_to_group("units", true)
	add_to_group("builders", true)
	add_to_group("player_units", true)
	navigation_agent.path_desired_distance = 10.0
	navigation_agent.target_desired_distance = 10.0
	update_health_bar()



func _process(_delta):
	# Обновляем позицию панели над юнитом
	if is_instance_valid(build_panel_instance):
		var screen_pos = get_viewport().get_canvas_transform() * global_position
		build_panel_instance.get_node("PanelContainer").position = screen_pos + Vector2(-50, -120)
	
	# Добыча
	_check_mining()

func set_selected(value):
	selected = value
	box.visible = value
	health_bar.visible = value

func _input(event):
	if not selected:
		return
	if event.is_action_pressed("RightClick"):
		var mouse_pos = get_global_mouse_position()
		var mineral = _get_mineral_at(mouse_pos)
		if mineral:
			_go_to_mineral(mineral)
			get_viewport().set_input_as_handled()

func _get_mineral_at(pos: Vector2) -> Node:
	var space = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collision_mask = 0xFFFFFFFF
	var results = space.intersect_point(query)
	for r in results:
		if r.collider.is_in_group("minerals"):
			return r.collider
	return null

func _go_to_mineral(mineral: Node) -> void:
	_stop_mining()
	target_mineral = mineral
	target_queue.clear()
	target_queue.append(mineral.global_position)
	_go_to_next_target()

func _go_to_next_target() -> void:
	if target_queue.size() == 0:
		is_moving = false
		return
	is_moving = true
	# ← Сбрасываем дистанции на стандартные
	navigation_agent.path_desired_distance = 10.0
	navigation_agent.target_desired_distance = 10.0
	navigation_agent.set_target_position(target_queue[0])

# ─── Физика ───────────────────────────────────────────────────────

func _physics_process(_delta):
	# ← Добыча проверяется отдельно от движения
	_check_mining()

	if is_moving:
		if navigation_agent.is_navigation_finished():
			is_moving = false
			target_queue.pop_front() if target_queue.size() > 0 else null
			if target_queue.size() > 0:
				_go_to_next_target()
			return

		var next_path_position = navigation_agent.get_next_path_position()
		var dir = position.direction_to(next_path_position)
		velocity = dir * Speed
		move_and_slide()
		if Builder is Sprite2D or Builder is AnimatedSprite2D:
			if velocity.x < 0:
				Builder.flip_h = true
			elif velocity.x > 0:
				Builder.flip_h = false
	else:
		velocity = Vector2.ZERO

# ─── Добыча проверяется по дистанции, независимо от движения ──────

func _check_mining() -> void:
	# Если есть цель-минерал — проверяем дистанцию
	if is_instance_valid(target_mineral):
		var dist = global_position.distance_to(target_mineral.global_position)
		if dist < 50.0:
			# Достаточно близко — начинаем добычу
			_start_mining(target_mineral)
			target_mineral = null
			is_moving = false
			navigation_agent.set_target_position(global_position)
			target_queue.clear()
	
	# Если добываем — проверяем что ещё рядом
	if is_mining and is_instance_valid(current_mineral):
		var dist = global_position.distance_to(current_mineral.global_position)
		if dist > 100.0:
			_stop_mining()

func _start_mining(mineral: Node) -> void:
	if not is_instance_valid(mineral):
		return
	current_mineral = mineral
	is_mining = true
	mineral.start_mining(self)

func _stop_mining() -> void:
	if is_instance_valid(current_mineral) and current_mineral.has_method("stop_mining"):
		current_mineral.stop_mining(self)
	current_mineral = null
	is_mining = false

func on_mineral_depleted() -> void:
	current_mineral = null
	is_mining = false

func open_build_panel() -> void:
	if is_instance_valid(build_panel_instance):
		build_panel_instance.queue_free()
		return

	if not build_panel_scene:
		return

	build_panel_instance = build_panel_scene.instantiate()
	get_tree().current_scene.add_child(build_panel_instance)
	build_panel_instance.build_selected.connect(_on_build_selected)
	build_panel_instance.layer = 10
	
	# ← Просто показываем в центре экрана
	var panel = build_panel_instance.get_node_or_null("PanelContainer")
	if panel:
		var viewport_size = get_viewport().get_visible_rect().size
		panel.position = viewport_size * 0.5 - panel.size * 0.5
		print("viewport_size: ", viewport_size, " panel.size: ", panel.size)
		
func _on_build_selected(building_type: String) -> void:
	build_panel_instance = null
	if not build_preview_scene:
		return

	var preview = build_preview_scene.instantiate()
	get_tree().current_scene.add_child(preview)
	preview.setup(building_type, self)
	
	

func take_damage(damage):
	HP -= damage
	update_health_bar()
	if HP <= 0:
		_stop_mining()
		queue_free()

func update_health_bar():
	health_bar.max_value = max_HP
	health_bar.value = HP
