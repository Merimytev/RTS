extends StaticBody2D

var POP = preload("res://Global/POP.tscn")

var totalTime = 50
var currTime

@onready var bar = $ProgressBar
@onready var timer = $Timer

func _ready() -> void:
	currTime = totalTime
	bar.max_value = totalTime
	timer.start()


func _process(delta: float) -> void:
	if currTime <= 10:
		energyCollected()


func _on_timer_timeout() -> void:
	currTime -= 1
	var tween = get_tree().create_tween()
	tween.tween_property(bar, "value", currTime, 0.1).set_trans(Tween.TRANS_LINEAR)

func energyCollected():
	Game.Energy += 10
	_ready()
	var pop = POP.instantiate()
	add_child(pop)
	pop.z_index = 1
	pop.show_value(str(10))
