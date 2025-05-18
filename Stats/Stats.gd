extends Node2D

var server_url = "http://127.0.0.1:5000"

func _ready() -> void:
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request(server_url + "/get_statistics")
	http_request.connect("request_completed", Callable(self, "_on_request_completed"))

func _on_request_completed(result: int, response_code: int, headers: Array, body: PackedByteArray) -> void:
	if response_code == 200:
		var response = body.get_string_from_utf8()
		print("Response: ", response)
		var json_parser = JSON.new()
		var json_result = json_parser.parse(response)
		
		if json_result == OK:
			var data = json_parser.data
			if typeof(data) == TYPE_ARRAY and data.size() > 0:
				var last_entry = data[data.size() - 1]
				if typeof(last_entry) == TYPE_DICTIONARY:
					$Name.text = str(last_entry.get("name_input", "Нет данных"))
					$Minerals.text = str(int(last_entry.get("minerals", 0)))
					$Energy.text = str(int(last_entry.get("energy", "Нет данных")))
					$Time.text = str(int(last_entry.get("time_played", "Нет данных"))) + " секунд"
				else:
					print("Ошибка: Ожидался словарь, но элемент массива имеет другой тип.")
			else:
				print("Ошибка: Получен пустой массив или неподходящий тип данных.")
		else:
			print("Ошибка парсинга JSON: ", json_parser.error_message)
	else:
		print("HTTP ошибка: ", response_code)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://MainMenu.tscn")
