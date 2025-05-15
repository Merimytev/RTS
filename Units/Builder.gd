extends CharacterBody2D

@export var selected = false
@onready var box = get_node("Box")
@onready var Builder = get_node("Builder")
@onready var navigation_agent = $NavigationAgent2D  # Ссылка на NavigationAgent2D


@onready var target = position
var follow_cursor = false
var Speed = 80
var HP = 60

func _ready():
	set_selected(selected)
	add_to_group("units", true)
	add_to_group("builders", true)
	# Настройка NavigationAgent2D
	navigation_agent.path_desired_distance = 10.0  # Расстояние, на котором путь считается завершённым
	navigation_agent.target_desired_distance = 10.0  # Расстояние до цели

func set_selected(value):
	selected = value
	box.visible = value
	
func _input(event):
	if event.is_action_pressed("RightClick"):
		follow_cursor = true
	if event.is_action_released("RightClick"):
		follow_cursor = false

func _physics_process(delta):
	if follow_cursor and selected:
		# Обновляем целевую позицию при движении курсора
		target = get_global_mouse_position()
		navigation_agent.set_target_position(target)

	# Если есть путь, двигаемся к следующей точке
	if navigation_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		return
		
	var next_path_position = navigation_agent.get_next_path_position()
	velocity = position.direction_to(next_path_position) * Speed

	# Двигаемся с использованием move_and_slide
	if position.distance_to(next_path_position) > navigation_agent.path_desired_distance:
		move_and_slide()
		
		
		
# Поворот спрайта
	if Builder is Sprite2D or Builder is AnimatedSprite2D:
		if velocity.x < 0: # налево
			Builder.flip_h = true
		elif velocity.x > 0: # направо
			Builder.flip_h = false
