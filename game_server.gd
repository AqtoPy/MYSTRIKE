extends Node

var map: String
var game_mode: String
var max_players: int
var password: String
var players = []

func initialize(map_name: String, mode: String, max_slots: int, server_password: String):
    map = map_name
    game_mode = mode
    max_players = max_slots
    password = server_password
    
    # Настройка сети
    var peer = ENetMultiplayerPeer.new()
    peer.create_server(7777, max_players)
    multiplayer.multiplayer_peer = peer
    
    # Загрузка режима
    load_game_mode(mode)

func load_game_mode(mode_name: String):
    var mode_path = "res://game_modes/%s.gd" % mode_name.to_lower().replace(" ", "_")
    if ResourceLoader.exists(mode_path):
        var mode_script = load(mode_path)
        var mode = mode_script.new()
        add_child(mode)
        mode.start_mode()

@rpc("any_peer")
func register_player(nickname: String, skin: String, is_vip: bool, is_dev: bool):
    var player_id = multiplayer.get_remote_sender_id()
    
    # Проверка разработчика
    if is_dev and not DeveloperTools.verify_developer(player_id):
        is_dev = false
    
    players.append({
        "id": player_id,
        "nickname": nickname,
        "skin": skin,
        "vip": is_vip,
        "developer": is_dev,
        "team": -1,
        "score": 0
    })
    
    # Уведомляем всех о новом игроке
    update_player_list()

@rpc("reliable")
func update_player_list():
    var player_data = []
    for p in players:
        player_data.append({
            "nickname": p["nickname"],
            "skin": p["skin"],
            "vip": p["vip"],
            "developer": p["developer"],
            "team": p["team"],
            "score": p["score"]
        })
    
    multiplayer.send_bytes(JSON.stringify(player_data).to_utf8_buffer())
