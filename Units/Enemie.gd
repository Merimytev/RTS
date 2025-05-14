extends CharacterBody2D

@export var HP = 100
@export var speed = 100
@export var damage = 10
@export var attack_range = 200.0
@export var detection_range = 300.0
@export var attack_rate = 1.0
@export var bullet_scene: PackedScene # Пуля (Bullet.tscn)

var target = null
var can_attack = true

func _ready():
	add_to_group("enemies")
	var timer = Timer.new()
	timer.wait_time = 1.0 / attack_rate
	timer.autostart = false
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_attack_timer_timeout"))
	add_child(timer)
	timer.name = "AttackTimer"

func _physics_process(delta):
	target = find_nearest_unit()
	
	if target:
		var distance = position.distance_to(target.position)
		if distance > attack_range:
			# Движение к цели
			velocity = position.direction_to(target.position) * speed
			move_and_slide()
		else:
			# Атака
			if can_attack:
				attack(target)
				can_attack = false
				$AttackTimer.start()
	else:
		velocity = Vector2.ZERO

func find_nearest_unit():
	var units = []
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	var shape = CircleShape2D.new()
	shape.radius = detection_range
	query.shape = shape
	query.transform = Transform2D(0, position)
	query.collision_mask = 1 << 0 # Юниты на слое 1 (индекс 0)
	
	var results = space_state.intersect_shape(query)
	for result in results:
		var collider = result.collider
		if collider.is_in_group("units"):
			units.append(collider)
	
	# Сортировка по расстоянию
	units.sort_custom(func(a, b): return position.distance_squared_to(a.position) < position.distance_squared_to(b.position))
	return units[0] if units else null

func attack(unit):
	if bullet_scene and is_instance_valid(unit):
		var bullet = bullet_scene.instantiate()
		bullet.position = position
		bullet.direction = (unit.position - position).normalized()
		get_tree().root.add_child(bullet)
		print("Enemy ", name, " fired bullet at: ", unit.position)

func take_damage(damage):
	HP -= damage
	if HP <= 0:
		queue_free()

func _on_attack_timer_timeout():
	can_attack = true
