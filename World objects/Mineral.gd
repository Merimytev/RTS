extends StaticBody2D



var totalTime = 5
var currTime
var units = 0
@onready var bar = $ProgressBar
@onready var timer = $Timer




func _ready():
	currTime = totalTime
	bar.max_value = totalTime



func _process(delta):
	bar.value = currTime
	if currTime <= 0:
		mineralMined()


func _on_mine_area_body_entered(body: Node2D) -> void:
	if "Unit" in body.name:
		units += 1
		startMining()
		

func _on_mine_area_body_exited(body: Node2D) -> void:
	if "Unit" in body.name:
		units -= 1
		if units <= 0:
			timer.stop()

func _on_timer_timeout() -> void:
	currTime -= 1*units
	var tween = get_node("Mineral").create_tween()
	tween.tween_property(bar, "value", currTime, 0.8).set_trans(Tween.TRANS_LINEAR)
	

func startMining():
	timer.start()
	
	
func mineralMined():
	Game.Mineral += 1
	queue_free()
