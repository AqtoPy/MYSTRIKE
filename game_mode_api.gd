class_name GameModeAPI
extends Node

# ========================
# 📌 БАЗОВЫЕ СВОЙСТВА
# ========================
signal mode_loaded()                  # Режим загружен
signal mode_started()                 # Режим начался
signal mode_ended(winner_team)        # Режим завершился
signal round_started(round_num)       # Раунд начался
signal round_ended(round_num)         # Раунд завершился

signal player_joined(player)          # Игрок присоединился
signal player_left(player)            # Игрок вышел
signal player_spawned(player)         # Игрок заспавнился
signal player_died(player, killer)    # Игрок умер
signal player_earned(player, amount)  # Игрок заработал валюту
signal player_spent(player, amount)   # Игрок потратил валюту

signal zone_entered(player, zone)     # Игрок вошел в зону
signal zone_exited(player, zone)      # Игрок вышел из зоны
signal item_purchased(player, item)   # Игрок купил предмет

var mode_name = "Custom Mode"         # Название режима
var mode_description = ""             # Описание режима
var mode_hint = ""                    # Подсказка (отображается сверху экрана)

var allow_weapons = true              # Разрешить оружие
var allow_purchases = false           # Разрешить покупки
var round_based = false               # Раундовый режим
var team_based = false                # Командный режим

# ========================
# 🛠 МЕТОДЫ УПРАВЛЕНИЯ
# ========================

func start_mode():
    """Запуск режима"""
    emit_signal("mode_started")
    update_hint()
    
    if round_based:
        start_round(1)

func end_mode(winner_team = -1):
    """Завершение режима"""
    emit_signal("mode_ended", winner_team)

func update_hint():
    """Обновить подсказку"""
    HUD.set_mode_hint(mode_hint)

# ========================
# 💰 ЭКОНОМИКА
# ========================

func add_shop_item(item_name, price, team = -1, limit = -1):
    """Добавить предмет в магазин"""
    Shop.add_item(item_name, price, team, limit)

func remove_shop_item(item_name):
    """Удалить предмет из магазина"""
    Shop.remove_item(item_name)

func give_currency(player, amount):
    """Выдать валюту игроку"""
    player.currency += amount
    emit_signal("player_earned", player, amount)

func take_currency(player, amount):
    """Забрать валюту у игрока"""
    player.currency = max(0, player.currency - amount)
    emit_signal("player_spent", player, amount)

# ========================
# 🎯 УПРАВЛЕНИЕ ОРУЖИЕМ
# ========================

func disable_weapons():
    """Запретить оружие"""
    allow_weapons = false
    for player in get_players():
        strip_weapons(player)

func enable_weapons():
    """Разрешить оружие"""
    allow_weapons = true

func strip_weapons(player):
    """Забрать оружие у игрока"""
    player.weapons = []
    player.current_weapon = null

func give_weapon(player, weapon_name):
    """Выдать оружие игроку"""
    if allow_weapons:
        player.add_weapon(weapon_name)

# ========================
# 📍 РАБОТА С ЗОНАМИ
# ========================

func create_zone(name, position, size, earn_rate = 0):
    """Создать зону"""
    var zone = ZoneManager.create_zone(name, position, size)
    zone.earn_rate = earn_rate
    return zone

func remove_zone(zone):
    """Удалить зону"""
    ZoneManager.remove_zone(zone)

# ========================
# 🎮 УПРАВЛЕНИЕ ИГРОКАМИ
# ========================

func spawn_player(player, team = -1):
    """Спавн игрока"""
    if team_based and team == -1:
        team = assign_team(player)
    
    player.spawn(get_spawn_point(team))
    
    if not allow_weapons:
        strip_weapons(player)
    
    emit_signal("player_spawned", player)

func teleport_player(player, position):
    """Телепортировать игрока"""
    player.position = position

# ========================
# 🛠 ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ
# ========================

func get_players():
    """Получить всех игроков"""
    return get_tree().get_nodes_in_group("players")

func get_teams():
    """Получить все команды"""
    return Teams.get_all()

func show_popup(title, text, duration = 3.0, style = "normal"):
    """Показать всплывающее сообщение"""
    PopupManager.show(title, text, duration, style)

func start_timer(name, duration):
    """Запустить таймер"""
    TimerSystem.start(name, duration)
