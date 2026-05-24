extends CharacterBody2D

# ═══ Настройки ═══════════════════════════════════════════════════
@export var selected = false
@export var speed := 100.0
@export var max_hp := 100.0
@export var attack_range := 200.0
@export var fire_rate := 1.0
@export var damage := 25.0
@export var bullet_scene: PackedScene

# ═══ Узлы ════════════════════════════════════════════════════════
@onready var box = $Box
@onready var health_bar = $Healthbar
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

# ═══ Состояние ═══════════════════════════════════════════════════
var hp := max_hp
var can_shoot := true
var target_queue: Array = []

# ─── Инициализация ────────────────────────────────────────────────

func _ready():
	hp = max_hp
	set_selected(selected)
	add_to_group("units", true)
	add_to_group("player_units", true)

	nav_agent.path_desired_distance = 10.0
	nav_agent.target_desired_distance = 10.0
	nav_agent.avoidance_enabled = true
	nav_agent.velocity_computed.connect(_on_velocity_computed)

	var timer = Timer.new()
	timer.name = "ShootTimer"
	timer.wait_time = 1.0 / fire_rate
	timer.one_shot = true
	timer.autostart = false
	timer.timeout.connect(_on_shoot_timer_timeout)
	add_child(timer)

	update_health_bar()

# ─── Выделение ────────────────────────────────────────────────────

func set_selected(value: bool) -> void:
	selected = value
	box.visible = value
	health_bar.visible = value




# ─── Физика ───────────────────────────────────────────────────────

func _physics_process(_delta):
	_update_movement()
	_shooting()

func _update_movement() -> void:
	if nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		if target_queue.size() > 0:
			target_queue.pop_front()  # ← удаляем только после достижения
			if target_queue.size() > 0:
				_go_to_next_target()
		return

	var next_pos = nav_agent.get_next_path_position()
	var dir = position.direction_to(next_pos)
	velocity = dir * speed

	if position.distance_to(next_pos) > nav_agent.path_desired_distance:
		nav_agent.set_velocity(velocity)

func _go_to_next_target() -> void:
	
	if target_queue.size() == 0:
		return
	var next = target_queue[0]  # ← front без pop
	nav_agent.set_target_position(next)

	


func _on_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()

# ─── Стрельба ─────────────────────────────────────────────────────

func _shooting() -> void:
	if not can_shoot:
		return
	var enemies = _get_enemies_in_range(attack_range)
	if enemies.is_empty():
		return
	_shoot(enemies[0])
	can_shoot = false
	$ShootTimer.start()

func _shoot(target_node: Node2D) -> void:
	if bullet_scene:
		var bullet = bullet_scene.instantiate()
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = global_position
		var dir = (target_node.global_position - global_position).normalized()
		if bullet.has_method("init"):
			bullet.init(dir, damage)
		return
	if target_node.has_method("take_damage"):
		target_node.take_damage(damage)

func _get_enemies_in_range(radius: float) -> Array:
	var enemies = []
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	var shape = CircleShape2D.new()
	shape.radius = radius
	query.shape = shape
	query.transform = Transform2D(0, global_position)
	query.collision_mask = 1
	var results = space_state.intersect_shape(query)
	for result in results:
		var collider = result.collider
		if is_instance_valid(collider) and collider.is_in_group("enemies"):
			enemies.append(collider)
	enemies.sort_custom(func(a, b):
		return global_position.distance_squared_to(a.global_position) 
		global_position.distance_squared_to(b.global_position)
	)
	return enemies

# ─── Таймер стрельбы ─────────────────────────────────────────────

func _on_shoot_timer_timeout() -> void:
	can_shoot = true

# ─── Урон и смерть ───────────────────────────────────────────────

func take_damage(amount: float) -> void:
	hp -= amount
	update_health_bar()
	if hp <= 0:
		queue_free()

func update_health_bar() -> void:
	health_bar.max_value = max_hp
	
	health_bar.value = hp
