extends Node2D


func _on_play_pressed() -> void:
	Game.reset_resources()
	get_tree().change_scene_to_file("res://world.tscn")


func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://SettingsMenu.tscn")


func _on_statistics_pressed() -> void:
	get_tree().change_scene_to_file("res://Stats/Stats.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
