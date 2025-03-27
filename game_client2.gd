class_name GameClient
extends Node

signal connected_to_server()
signal connection_failed()
signal disconnected_from_server()

var player_info := {
    "name": "Игрок",
    "character": "soldier",
    "ready": false
}

func connect_to_server(ip: String, port: int = 9080):
    var peer = ENetMultiplayerPeer.new()
    var error = peer.create_client(ip, port)
    
    if error != OK:
        push_error("Ошибка подключения: %d" % error)
        emit_signal("connection_failed")
        return
    
    multiplayer.multiplayer_peer = peer
    multiplayer.connected_to_server.connect(_on_connected)
    multiplayer.connection_failed.connect(_on_connection_failed)
    multiplayer.server_disconnected.connect(_on_disconnected)

func _on_connected():
    emit_signal("connected_to_server")
    register_player.rpc_id(1, player_info)

func _on_connection_failed():
    emit_signal("connection_failed")

func _on_disconnected():
    emit_signal("disconnected_from_server")

@rpc("any_peer", "call_local")
func receive_chat_message(sender_id: int, message: String):
    var sender = get_player_by_id(sender_id)
    print("[Чат] %s: %s" % [sender.name, message])
