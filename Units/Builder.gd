extends CharacterBody2D

@export var selected = false
@onready var box = get_node("Box")
@onready var Builder = get_node("Builder")
@onready var navigation_agent = $NavigationAgent2D 
@onready var health_bar = $Healthbar

@onready var target = position
var follow_cursor = false
var Speed = 80
var HP = 60
var max_HP = 60  # Максимальное HP для ProgressBar
var target_queue = []  # Очередь целей

func _ready():
	set_selected(selected)
	add_to_group("units", true)
	add_to_group("builders", true)
	navigation_agent.path_desired_distance = 10.0  # Расстояние, на котором путь считается завершённым
	navigation_agent.target_desired_distance = 10.0  # Расстояние до цели
	update_health_bar()

func set_selected(value):
	selected = value
	box.visible = value
	health_bar.visible = value
	
func _input(event):
	if event.is_action_pressed("RightClick") and selected:
		var new_target = get_global_mouse_position()
		if Input.is_key_pressed(KEY_SHIFT):  # Если зажат Shift, добавляем в очередь
			target_queue.append(new_target)
		else:  # Если Shift не зажат, очищаем очередь и задаём новую цель
			target_queue.clear()
			target_queue.append(new_target)
			target = new_target
			navigation_agent.set_target_position(target)

func _physics_process(_delta):
	if target_queue.size() > 0:  # Если есть цели в очереди
		if navigation_agent.is_navigation_finished():  # Если текущая цель достигнута
			target_queue.pop_front()  # Удаляем выполненную цель
			if target_queue.size() > 0:  # Если есть следующая цель
				target = target_queue.front()  # Берём следующую цель
				navigation_agent.set_target_position(target)
			else:
				velocity = Vector2.ZERO  # Останавливаемся, если целей больше нет
				return
	else:
		velocity = Vector2.ZERO  # Нет целей — стоим на месте
		return

	if navigation_agent.is_navigation_finished():
		return
		
	var next_path_position = navigation_agent.get_next_path_position()
	velocity = position.direction_to(next_path_position) * Speed

	if position.distance_to(next_path_position) > navigation_agent.path_desired_distance:
		move_and_slide()
		
	if Builder is Sprite2D or Builder is AnimatedSprite2D:
		if velocity.x < 0:  # Налево
			Builder.flip_h = true
		elif velocity.x > 0:  # Направо
			Builder.flip_h = false

func take_damage(damage):
	HP -= damage
	update_health_bar()
	if HP <= 0:
		queue_free()

func update_health_bar():
	health_bar.max_value = max_HP
	health_bar.value = HP
