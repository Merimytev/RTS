extends Area2D

var speed = 400
var damage = 20
var direction = Vector2.RIGHT
var shooter_group = "" # Группа стреляющего ("units" или "enemies")

func _ready():
	print("Bullet created at: ", position, " direction: ", direction, " shooter_group: ", shooter_group)

func _physics_process(delta):
	position += direction * speed * delta

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
