extends CanvasLayer


@onready var Minerals = $Minerals
@onready var Energy = $Energy


func _process(delta: float) -> void:
	Minerals.text = "Minerals: " + str(Game.Minerals)
	Energy.text = "Energy: " + str(Game.Energy)


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://MainMenu.tscn")
