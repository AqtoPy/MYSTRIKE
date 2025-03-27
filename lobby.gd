extends Control

@onready var player_list = $PlayerList
@onready var chat_display = $ChatDisplay
@onready var chat_input = $ChatInput
@onready var start_button = $StartButton
@onready var team_button = $TeamButton

var players = []
var is_host = false

func _ready():
    # Проверяем, является ли игрок хостом
    is_host = multiplayer.is_server()
    start_button.visible = is_host
    
    # Подключаем сигналы
    GameServer.player_list_updated.connect(_on_player_list_updated)
    GameServer.chat_message_received.connect(_on_chat_message_received)
    
    # Загружаем список игроков
    _on_player_list_updated(GameServer.get_player_list())

func _on_player_list_updated(player_data):
    players = player_data
    player_list.clear()
    
    for player in players:
        var player_text = player["nickname"]
        if player["vip"]:
            player_text = "[VIP] " + player_text
        if player["developer"]:
            player_text = "[DEV] " + player_text
        
        player_list.add_item(player_text)
        
        # Показываем команду
        if player["team"] != -1:
            player_list.set_item_text(player_list.item_count - 1, 
                                   player_text + " (Team %d)" % (player["team"] + 1))

func _on_chat_message_received(sender_id, message):
    var sender = get_player_by_id(sender_id)
    if sender:
        chat_display.append_text("[color=%s]%s:[/color] %s\n" % [
            "gold" if sender["vip"] else "white",
            sender["nickname"],
            message
        ])

func get_player_by_id(player_id):
    for player in players:
        if player["id"] == player_id:
            return player
    return null

func _on_chat_input_text_submitted(new_text):
    if new_text.strip() != "":
        GameServer.send_chat_message.rpc_id(1, new_text) # Отправляем на сервер
        chat_input.clear()

func _on_start_button_pressed():
    GameServer.start_game.rpc()

func _on_team_button_pressed():
    GameServer.change_team.rpc_id(1) # Запрос на смену команды

func _on_ready_button_pressed():
    GameServer.toggle_ready.rpc_id(1)
