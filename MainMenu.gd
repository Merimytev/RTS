extends Node2D


func _ready() -> void:
	get_node("VBoxContainer/Play").grab_focus()

func _on_play_pressed() -> void:
	Game.reset_resources()
	get_tree().change_scene_to_file("res://world.tscn")


func _on_pause_pressed() -> void:
	pass # Replace with function body.


func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://SettingsMenu.tscn")


func _on_statistics_pressed() -> void:
	get_tree().change_scene_to_file("res://Stats/Stats.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
