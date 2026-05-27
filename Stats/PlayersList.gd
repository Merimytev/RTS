extends CanvasLayer

const SERVER_URL = "http://127.0.0.1:5000"
const FONT_PATH = "res://img/fonts/Orbit-Regular.ttf"

@onready var player_list: VBoxContainer = $Panel/VBoxContainer/ScrollContainer/PlayerListContainer
@onready var back_btn: Button = $Panel/VBoxContainer/Back

func _ready() -> void:
	back_btn.pressed.connect(_on_back_pressed)
	var http := HTTPRequest.new()
	add_child(http)
	http.request(SERVER_URL + "/get_statistics")
	http.request_completed.connect(_on_request_completed)

func _on_request_completed(
		_result: int, response_code: int, _headers: Array, body: PackedByteArray
) -> void:
	if response_code != 200:
		print("HTTP ошибка: ", response_code)
		return
	var json_parser := JSON.new()
	if json_parser.parse(body.get_string_from_utf8()) != OK:
		return
	var data = json_parser.data
	print("DATA TYPE: ", typeof(data), " | VALUE: ", data)
	if typeof(data) != TYPE_ARRAY:
		return
	print("ENTRIES COUNT: ", data.size())
	for entry in data:
		if typeof(entry) == TYPE_DICTIONARY:
			_add_player_button(entry)

func _add_player_button(entry: Dictionary) -> void:
	var btn := Button.new()
	btn.text = str(entry.get("name_input", "—"))
	btn.custom_minimum_size = Vector2(0, 44)
	btn.size_flags_horizontal = Control.SIZE_FILL | Control.SIZE_EXPAND
	btn.add_theme_font_override("font", load(FONT_PATH))
	btn.add_theme_font_size_override("font_size", 22)
	btn.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	var sn := StyleBoxFlat.new()
	sn.bg_color = Color(0.09, 0.12, 0.20, 0.90)
	sn.set_border_width_all(1)
	sn.border_color = Color(0.28, 0.42, 0.68, 0.80)
	sn.set_corner_radius_all(5)
	btn.add_theme_stylebox_override("normal", sn)
	var sh := StyleBoxFlat.new()
	sh.bg_color = Color(0.15, 0.21, 0.36, 0.97)
	sh.set_border_width_all(1)
	sh.border_color = Color(0.50, 0.72, 1.0, 1.0)
	sh.set_corner_radius_all(5)
	btn.add_theme_stylebox_override("hover", sh)
	btn.pressed.connect(_on_player_selected.bind(entry))
	player_list.add_child(btn)

func _on_player_selected(entry: Dictionary) -> void:
	Game.selected_player = entry
	get_tree().change_scene_to_file("res://Stats/Stats.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://MainMenu.tscn")
