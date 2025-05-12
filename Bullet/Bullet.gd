extends Area2D

var speed = 400
var damage = 20
var direction = Vector2.RIGHT
var shooter_group = "" # Группа стреляющего ("units" или "enemies")
var shooter = null # Ссылка на стреляющего (Soldier или Enemy)
var target = null
var min_distance = 10.0 # Минимальное расстояние до цели, чтобы избежать "залипания"

@onready var BulletSprite = $Sprite2D

func _ready():
	print("Bullet created at: ", position, " direction: ", direction, " shooter_group: ", shooter_group)
	find_target()
	if target and is_instance_valid(target):
		var distance_to_target = global_position.distance_to(target.global_position)
		if distance_to_target > min_distance:
			direction = (target.global_position - global_position).normalized()
		else:
			print("Target too close, keeping default direction")
		print("Initial direction set to: ", direction)
	
func find_target():
	# Определяем группу врагов в зависимости от shooter_group
	var target_group = "enemies" if shooter_group == "units" else "units"
	var targets = get_tree().get_nodes_in_group(target_group)
	
	# Находим ближайшего врага
	var closest_distance = INF
	for t in targets:
		if is_instance_valid(t) and t != shooter: # Исключаем самого стреляющего
			var distance = global_position.distance_to(t.global_position)	
			if distance < closest_distance:
				closest_distance = distance
				target = t
	
	if target:
		print("Target acquired: ", target.name, " at ", target.global_position)
	else:
		print("No target found for shooter_group: ", shooter_group)

func _physics_process(delta):
	if is_instance_valid(target):
		# Обновляем направление к цели
		var distance_to_target = global_position.distance_to(target.global_position)
		if distance_to_target > min_distance:
			direction = (target.global_position - global_position).normalized()
		else:
			print("Target too close, keeping current direction")
		print("Bullet moving towards target: ", target.name, " direction: ", direction)
	else:
		# Если цель пропала, ищем новую
		find_target()
		if not target:
			print("No valid target, continuing with direction: ", direction)
	
	# Двигаем пулю
	position += direction * speed * delta
	print("Bullet position: ", position) # Отладка позиции
	
	# Поворачиваем спрайт пули
	if BulletSprite is Sprite2D:
		BulletSprite.rotation = direction.angle() # Поворот в направлении движения

func _on_body_entered(body):
	if is_instance_valid(body):
		if shooter_group == "enemies" and body.is_in_group("units"):
			if body.has_method("take_damage"):
				body.take_damage(damage)
				print("Пуля попала в юнита: ", body.name, " в ", body.position)
			queue_free() # Исчезает при столкновении
		elif shooter_group == "units" and body.is_in_group("enemies"):
			if body.has_method("take_damage"):
				body.take_damage(damage)
				print("Пуля попала в юнита: ", body.name, " в ", body.position)
			queue_free() # Исчезает при столкновении
	else:
		print("Bullet hit invalid body: ", body)

func _on_visible_on_screen_notifier_2d_screen_exited():
	print("Bullet exited screen at: ", position)
	queue_free()
