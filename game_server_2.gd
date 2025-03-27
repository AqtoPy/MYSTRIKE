class_name GameServer
extends Node

# Сигналы сервера
signal player_connected(player_id: int)
signal player_disconnected(player_id: int)
signal player_ready(player_id: int)
signal player_died(victim: Node, killer: Node)

const PORT := 9080
const MAX_PLAYERS := 12

var players := {}
var current_game_mode: GameMode

func _ready():
    multiplayer.peer_connected.connect(_on_peer_connected)
    multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func start_server(game_mode: String, max_players := MAX_PLAYERS):
    var peer = ENetMultiplayerPeer.new()
    var error = peer.create_server(PORT, max_players)
    
    if error != OK:
        push_error("Не удалось создать сервер: %d" % error)
        return false
    
    multiplayer.multiplayer_peer = peer
    load_game_mode(game_mode)
    return true

func load_game_mode(mode_name: String):
    var mode_script = GameModeLoader.get_mode_script(mode_name)
    if mode_script:
        current_game_mode = mode_script.new()
        add_child(current_game_mode)
        current_game_mode.initialize()

func _on_peer_connected(player_id: int):
    print("Игрок подключен: ", player_id)
    players[player_id] = {"id": player_id, "ready": false}
    emit_signal("player_connected", player_id)

func _on_peer_disconnected(player_id: int):
    print("Игрок отключен: ", player_id)
    players.erase(player_id)
    emit_signal("player_disconnected", player_id)
