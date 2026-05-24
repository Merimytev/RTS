extends CanvasLayer

@onready var MineralsLabel = $Minerals
@onready var EnergyLabel = $Energy

func _ready():
	$Button.pressed.connect(_on_build_button_pressed)

func _process(_delta: float) -> void:
	MineralsLabel.text = "Minerals: " + str(Game.Minerals)
	EnergyLabel.text = "Energy: " + str(Game.Energy)

func _on_menu_pressed() -> void:
	print("Игрок вышел из игры без отправки данных")
	get_tree().change_scene_to_file("res://MainMenu.tscn")

func _on_build_button_pressed() -> void:
	print("кнопка нажата!")
	var builders = get_tree().get_nodes_in_group("builders")
	print("строителей: ", builders.size())
	for b in builders:
		print("builder selected: ", b.get("selected"))
		if b.get("selected") == true:
			b.open_build_panel()
			break
