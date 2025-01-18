extends CanvasLayer

@onready var MineralsLabel = $Minerals
@onready var EnergyLabel = $Energy

var server_url = "http://127.0.0.1:5000"

func _process(delta: float) -> void:
	MineralsLabel.text = "Minerals: " + str(Game.Minerals)
	EnergyLabel.text = "Energy: " + str(Game.Energy)

func send_data(minerals, energy, time):
	if minerals == null or energy == null or time == null:
		print("Ошибка: Одно или несколько значений пустые")
		return

	var http_request = HTTPRequest.new()
	add_child(http_request)

	var url = server_url + "/submit_data" + "?minerals=" + str(minerals) + "&energy=" + str(energy) + "&time=" + str(time)

	print("Отправляем запрос:", url)

	http_request.connect("request_completed", Callable(self, "_on_request_completed"))
	http_request.request(url)
	print("Запрос отправлен.")

func _on_request_completed(result: int, response_code: int, headers: Array, body: PackedByteArray) -> void:
	print("Response Code: ", response_code)
	if response_code == 200:
		var response = body.get_string_from_utf8()
		print("Response: ", response)
	else:
		print("Ошибка при отправке запроса, статус код: ", response_code)

func _on_menu_pressed() -> void:
	print("Нажата кнопка меню")
	var world_node = get_tree().root.get_node_or_null("World")

	if world_node:
		var time_elapsed = world_node.get_elapsed_time()
		time_elapsed = int(time_elapsed)
		print("Время, прошедшее в игре: ", time_elapsed)
		send_data(Game.Minerals, Game.Energy, time_elapsed)
	else:
		print("Узел 'World' не найден в дереве сцены.")
		send_data(Game.Minerals, Game.Energy, 0)

	await get_tree().create_timer(0.1).timeout

	get_tree().change_scene_to_file("res://MainMenu.tscn")
