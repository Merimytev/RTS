extends StaticBody2D

var mouseEntered = false
@onready var select = get_node("Selected")
var Selected = false

func _process(_delta: float) -> void:
	select.visible = Selected

func _input(event):
	if event.is_action_pressed("LeftClick"):
		if mouseEntered == true:
			Selected = !Selected
			if Selected == true:
				Game.spawnUnit(position)


func _on_factory_building_mouse_entered() -> void:
	mouseEntered = true

func _on_factory_building_mouse_exited() -> void:
	mouseEntered = false
