extends StaticBody2D

@export var total_minerals := 100
@export var minerals_per_tick := 10
@export var mine_time := 2.0

var current_minerals := total_minerals
var mining_units: Array = []

@onready var bar = $ProgressBar
@onready var timer = $Timer

func _ready():
	add_to_group("minerals", true)
	bar.max_value = total_minerals
	bar.value = current_minerals
	timer.wait_time = mine_time
	timer.one_shot = false

func _process(_delta):
	bar.value = current_minerals
	
	# Чистим рабочих которые ушли слишком далеко
	var active_units = []
	for u in mining_units:
		if is_instance_valid(u):
			var dist = global_position.distance_to(u.global_position)
			if dist < 80.0:
				active_units.append(u)
			else:
				# Юнит ушёл — останавливаем его добычу
				if u.has_method("on_mineral_depleted"):
					u.on_mineral_depleted()
	mining_units = active_units
	
	if mining_units.is_empty() and not timer.is_stopped():
		timer.stop()


func start_mining(builder: Node) -> void:
	if not mining_units.has(builder):
		mining_units.append(builder)
	if timer.is_stopped():
		timer.start()

func stop_mining(builder: Node) -> void:
	mining_units.erase(builder)
	if mining_units.is_empty():
		timer.stop()

func _on_timer_timeout() -> void:
	mining_units = mining_units.filter(func(u): return is_instance_valid(u))
	if mining_units.is_empty():
		timer.stop()
		return

	var mined = min(minerals_per_tick * mining_units.size(), current_minerals)
	current_minerals -= mined
	Game.Minerals += mined
	Game.minerals_send += mined

	var tween = create_tween()
	tween.tween_property(bar, "value", current_minerals, 0.5)

	if current_minerals <= 0:
		_depleted()

func _depleted() -> void:
	timer.stop()
	for builder in mining_units:
		if is_instance_valid(builder) and builder.has_method("on_mineral_depleted"):
			builder.on_mineral_depleted()
	queue_free()
