extends CanvasLayer

@onready var WinPanel: Panel = $Menu
@onready var NameInput: TextEdit = $Menu/PlayerName

var _won: bool = false
var server_url = "http://127.0.0.1:5000"

func _ready() -> void:
	WinPanel.visible = false
	Game.connect("minerals_changed", Callable(self, "_on_minerals_changed"))

func _on_minerals_changed(val:int) -> void:
	if not _won and val >= 100:
		_won = true
		_show_victory()

func _show_victory() -> void:
	# Останавливание времени
	get_tree().paused = true
	WinPanel.visible = true
	
func send_data(name_input:String, minerals:int, energy:int, time_played:int) -> void:
	if name_input.strip_edges() == "":
		print("Ошибка: имя пустое")
		return
		
	var http_request = HTTPRequest.new()
	add_child(http_request) # Создание http узла
	
	var encoded_name = name_input.uri_encode() # кодировка для валидации имён
	var url := "%s/submit_data?name_input=%s&minerals=%d&energy=%d&time=%d" % [ 
		server_url, encoded_name, minerals, energy, time_played]
		
	print("Отправляем запрос: ", url)
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
		print("Время, прошедшее в игре: ", time_elapsed, "секунд")
		send_data(NameInput.text, Game.Minerals, Game.Energy, time_elapsed)
		print("Отправлены данные об игре на БД")
	else:
		print("Узел 'World' не найден в дереве сцены.")
		send_data(NameInput.text, Game.Minerals, Game.Energy, 0)
		print("Отправлены ПУСТЫЕ данные об игре на БД")

	await get_tree().create_timer(0.1).timeout
	
	get_tree().paused = false # Снятие игры с паузы
	get_tree().change_scene_to_file("res://Stats/Stats.tscn")
