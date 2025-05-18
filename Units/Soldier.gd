extends CharacterBody2D

@export var selected = false
@onready var box = get_node("Box")
@onready var navigation_agent = $NavigationAgent2D 
@onready var target = position
@onready var health_bar = $Healthbar
var follow_cursor = false
var Speed = 100
var HP = 100
var max_hp = 100

@export var attack_range = 200.0
@export var fire_rate = 1.0
@export var damage = 25
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

	navigation_agent.path_desired_distance = 20.0
	navigation_agent.target_desired_distance = 10.0
	update_health_bar()
	
func set_selected(value):
	selected = value
	box.visible = value
	health_bar.visible = value
	print("Soldier ", name, " selected: ", selected)
	

func _input(event):
	if event.is_action_pressed("RightClick"):
		follow_cursor = true
	if event.is_action_released("RightClick"):
		follow_cursor = false

func _physics_process(_delta):
	if follow_cursor and selected:
		target = get_global_mouse_position()
		navigation_agent.set_target_position(target)

	if navigation_agent.is_navigation_finished():
		velocity = Vector2.ZERO
	else:
		var next_path_position = navigation_agent.get_next_path_position()
		velocity = position.direction_to(next_path_position) * Speed
		if position.distance_to(next_path_position) > navigation_agent.path_desired_distance:
			move_and_slide()

	_shooting()

func _shooting():
	var units_in_area = get_units_in_area(attack_range)
	if units_in_area.size() > 0 and can_shoot:
		var target_enemy = units_in_area[0]
		if target_enemy.has_method("take_damage"):
			target_enemy.take_damage(damage)
			print("Soldier attacked ", target_enemy.name, " for ", damage, " damage")
		else:
			print("Target has no take_damage method")
		can_shoot = false
		$ShootTimer.start()

func get_units_in_area(radius: float):
	var enemies = []
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	var shape = CircleShape2D.new()
	shape.radius = radius
	query.shape = shape
	query.transform = Transform2D(0, position)
	query.collision_mask = 1 << 0 # слой

	var results = space_state.intersect_shape(query)
	for result in results:
		var collider = result.collider
		if collider.is_in_group("enemies"):
			enemies.append(collider)
	
	enemies.sort_custom(func(a, b): return position.distance_squared_to(a.position) < position.distance_squared_to(b.position))
	return enemies

func _on_shoot_timer_timeout():
	can_shoot = true

func take_damage(damage):
	HP -= damage
	update_health_bar()
	if HP <= 0:
		queue_free()

func update_health_bar():
	health_bar.max_value = max_hp
	health_bar.value = HP
