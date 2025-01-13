extends CanvasLayer


@onready var label = $Label

func _process(delta: float) -> void:
	label.text = "Minerals: " + str(Game.Mineral)
