extends CharacterBody2D

@export var selected = false
@onready var box = get_node("Box")
@onready var Builder = get_node("Builder")


@onready var target = position
var follow_cursor = false
var Speed = 80
var HP = 60

func _ready():
	set_selected(selected)
	add_to_group("units", true)
	add_to_group("builders", true)

func set_selected(value):
	selected = value
	box.visible = value
	
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
		
# Поворот спрайта
	if Builder is Sprite2D or Builder is AnimatedSprite2D:
		if velocity.x < 0: # налево
			Builder.flip_h = true
		elif velocity.x > 0: # направо
			Builder.flip_h = false
