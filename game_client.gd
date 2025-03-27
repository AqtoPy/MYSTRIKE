extends Node

var server_ip = "127.0.0.1"
var server_port = 7777
var password = ""

func connect_to_server(ip: String, port: int, server_password: String):
    server_ip = ip
    server_port = port
    password = server_password
    
    var peer = ENetMultiplayerPeer.new()
    var error = peer.create_client(ip, port)
    
    if error != OK:
        show_error("Connection failed: %d" % error)
        return
    
    multiplayer.multiplayer_peer = peer
    multiplayer.connected_to_server.connect(_on_connected)
    multiplayer.connection_failed.connect(_on_connection_failed)

func _on_connected():
    # Регистрируем игрока на сервере
    GameServer.register_player.rpc_id(
        1, 
        PlayerData.data["nickname"],
        PlayerData.data["equipped_skin"],
        PlayerData.data["vip"],
        PlayerData.data["developer"]
    )
    
    get_tree().change_scene_to_file("res://ui/lobby.tscn")

func _on_connection_failed():
    show_error("Connection to server failed")

func show_error(message: String):
    var error_popup = preload("res://ui/error_popup.tscn").instantiate()
    error_popup.set_message(message)
    get_tree().root.add_child(error_popup)
