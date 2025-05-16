extends CanvasLayer

@onready var MineralsLabel = $Minerals
@onready var EnergyLabel = $Energy

func _process(delta: float) -> void:
	MineralsLabel.text = "Minerals: " + str(Game.Minerals)
	EnergyLabel.text = "Energy: " + str(Game.Energy)

func _on_menu_pressed() -> void:
	print("Игрок вышел из игры без отправки данных")

	get_tree().change_scene_to_file("res://MainMenu.tscn")
