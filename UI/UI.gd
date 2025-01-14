extends CanvasLayer


@onready var Minerals = $Minerals
@onready var Energy = $Energy


func _process(delta: float) -> void:
	Minerals.text = "Minerals: " + str(Game.Mineral)
	Energy.text = "Energy: " + str(Game.Energy)
