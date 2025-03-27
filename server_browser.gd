extends Control

@onready var server_list = $ServerList
@onready var refresh_button = $RefreshButton
@onready var connect_button = $ConnectButton
@onready var password_edit = $PasswordEdit

var servers = []

func _ready():
    refresh_servers()

func refresh_servers():
    server_list.clear()
    servers = []
    
    # Здесь должен быть код получения списка серверов
    # Например, через Steamworks или мастер-сервер
    
    # Пример заполнения
    add_server("Лучший сервер", "192.168.1.100", 7777, "Forest", "Deathmatch", 4, 8, false)
    add_server("Турнирный", "192.168.1.101", 7777, "City", "CTF", 6, 8, true)

func add_server(name, ip, port, map, mode, players, max_players, password_protected):
    var text = "%s [%s/%s] - %s (%s)" % [name, players, max_players, map, mode]
    if password_protected:
        text += " [LOCKED]"
    server_list.add_item(text)
    servers.append({
        "ip": ip,
        "port": port,
        "password_protected": password_protected
    })

func _on_connect_pressed():
    var selected = server_list.get_selected_items()
    if selected.size() == 0:
        return
        
    var server = servers[selected[0]]
    
    if server["password_protected"] and password_edit.text == "":
        show_error("Этот сервер требует пароль!")
        return
    
    # Подключаемся
    var client = preload("res://networking/game_client.tscn").instantiate()
    client.connect_to_server(server["ip"], server["port"], password_edit.text)
    get_tree().root.add_child(client)
    
    get_tree().change_scene_to_file("res://ui/lobby.tscn")

func _on_refresh_pressed():
    refresh_servers()

func show_error(message):
    var popup = preload("res://ui/error_popup.tscn").instantiate()
    popup.set_message(message)
    add_child(popup)
