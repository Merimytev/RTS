extends CanvasLayer

var _won: bool = false
var _is_victory: bool = false
var server_url = "http://127.0.0.1:5000"

@onready var win_panel: Panel = $Menu
@onready var name_input: TextEdit = $Menu/PlayerName
@onready var status_label: Label = $Menu/Label

func _ready() -> void:
	win_panel.visible = false
	Game.connect("base_destroyed", Callable(self, "_on_victory"))
	Game.connect("player_defeated", Callable(self, "_on_defeat"))

func _on_victory() -> void:
	if not _won:
		_won = true
		_is_victory = true
		_show_end_screen("Вы победили!")

func _on_defeat() -> void:
	if not _won:
		_won = true
		_is_victory = false
		_show_end_screen("Вы проиграли!")

func _show_end_screen(title_text: String) -> void:
	status_label.text = title_text
	get_tree().paused = true
	win_panel.visible = true

func send_data(
		player_name: String, minerals: int, energy: int, time_played: int, killed: int
) -> void:
	if player_name.strip_edges() == "":
		print("Ошибка: имя пустое")
		return

	var http_request = HTTPRequest.new()
	add_child(http_request)

	var encoded_name = player_name.uri_encode()
	var url := "%s/submit_data?name_input=%s&minerals=%d&energy=%d&time=%d&killed=%d" % [
		server_url, encoded_name, minerals, energy, time_played, killed]

	print("Отправляем запрос: ", url)
	http_request.connect("request_completed", Callable(self, "_on_request_completed"))
	http_request.request(url)
	print("Запрос отправлен.")

func _on_request_completed(_result: int, response_code: int, _headers: Array, body: PackedByteArray) -> void:
	print("Response Code: ", response_code)
	if response_code == 200:
		var response = body.get_string_from_utf8()
		print("Response: ", response)
	else:
		print("Ошибка при отправке запроса, статус код: ", response_code)

func _on_menu_pressed() -> void:
	if name_input.text.strip_edges() == "":
		var tween = create_tween()
		tween.tween_property(name_input, "modulate", Color(1.0, 0.3, 0.3), 0.1)
		tween.tween_property(name_input, "modulate", Color(1.0, 1.0, 1.0), 0.3)
		return

	print("Нажата кнопка меню")
	var world_node = get_tree().root.get_node_or_null("World")

	if world_node:
		var time_elapsed = int(world_node.get_elapsed_time())
		print("Время, прошедшее в игре: ", time_elapsed, "секунд")
		send_data(name_input.text, Game.Minerals, Game.Energy, time_elapsed, Game.killed_count)
		print("Отправлены данные об игре на БД")
	else:
		print("Узел 'World' не найден в дереве сцены.")
		send_data(name_input.text, Game.Minerals, Game.Energy, 0, Game.killed_count)
		print("Отправлены ПУСТЫЕ данные об игре на БД")

	await get_tree().create_timer(0.1).timeout

	get_tree().paused = false
	get_tree().change_scene_to_file("res://Stats/Stats.tscn")
