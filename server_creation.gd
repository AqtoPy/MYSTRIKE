extends Control

@onready var map_option = $MapOption
@onready var mode_option = $ModeOption
@onready var max_players_slider = $MaxPlayersSlider
@onready var password_edit = $PasswordEdit

var available_maps = ["Forest", "City", "Desert"]
var available_modes = ["Deathmatch", "Team Deathmatch", "Capture the Flag"]

func _ready():
    for map in available_maps:
        map_option.add_item(map)
    for mode in available_modes:
        mode_option.add_item(mode)

func _on_create_pressed():
    var selected_map = available_maps[map_option.selected]
    var selected_mode = available_modes[mode_option.selected]
    var max_players = max_players_slider.value
    var password = password_edit.text
    
    # Создаем сервер
    var server = preload("res://networking/game_server.tscn").instantiate()
    server.initialize(selected_map, selected_mode, max_players, password)
    get_tree().root.add_child(server)
    
    # Переходим в лобби
    get_tree().change_scene_to_file("res://ui/lobby.tscn")

func _on_back_pressed():
    get_tree().change_scene_to_file("res://ui/main_menu.tscn")
