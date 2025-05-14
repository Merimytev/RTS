extends CharacterBody2D

@export var selected = false
@onready var box = get_node("Box")

@onready var target = position
var follow_cursor = false
var Speed = 100
var HP = 100

@export var attack_range = 200.0
@export var fire_rate = 1.0
@export var bullet_scene: PackedScene # Пуля (Bullet.tscn)
var can_shoot = true

func _ready():
	set_selected(selected)
	add_to_group("units", true)
	
	var timer = Timer.new()
	timer.wait_time = 1.0 / fire_rate
	timer.autostart = false
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_shoot_timer_timeout"))
	add_child(timer)
	timer.name = "ShootTimer"
	
	if not bullet_scene:
		print("Warning: bullet_scene not set in ", name)

func set_selected(value):
	selected = value
	box.visible = value
	print("Soldier ", name, " selected: ", selected) # Отладка
	
func _input(event):
	if event.is_action_pressed("RightClick"):
		follow_cursor = true
	if event.is_action_released("RightClick"):
		follow_cursor = false

func _physics_process(delta):
	if follow_cursor == true:
		if selected:
			target = get_global_mouse_position()
	velocity = position.direction_to(target)*Speed
	if position.distance_to(target) > 10:
		move_and_slide()
	else:
		pass
		
	_shooting()
	
func _shooting():
	var units_in_area = get_units_in_area(attack_range)
	print("Enemies in range: ", units_in_area) # Отладка
	if units_in_area and can_shoot:
		_shoot(units_in_area[0]) # Стреляем в ближайшего врага
		can_shoot = false
		$ShootTimer.start()
	elif not bullet_scene:
		print("Cannot shoot: bullet_scene is null")

func _shoot(enemy):
	var bullet = bullet_scene.instantiate()
	bullet.position = position
	bullet.direction = (enemy.position - position).normalized()
	get_tree().root.add_child(bullet)
	print("Bullet fired at: ", enemy.position) # Отладка

func get_units_in_area(radius: float):
	var enemies = []
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	var shape = CircleShape2D.new()
	shape.radius = radius
	query.shape = shape
	query.transform = Transform2D(0, position)
	query.collision_mask = 1 << 0 # Юниты на слое 1 (индекс 0)
	
	var results = space_state.intersect_shape(query)
	for result in results:
		var collider = result.collider
		if collider.is_in_group("enemies"):
			enemies.append(collider)
	
	# Сортируем по расстоянию
	enemies.sort_custom(func(a, b): return position.distance_squared_to(a.position) < position.distance_squared_to(b.position))
	return enemies

func _on_shoot_timer_timeout():
	can_shoot = true
	print("Shoot timer reset, can_shoot: ", can_shoot) # Отладка
	
func take_damage(damage):
	HP -= damage
	if HP <= 0:
		queue_free()
