class_name GameAPI
extends Node

# ========================
# 🎮 ЯДРО СИСТЕМЫ
# ========================
enum MatchState { LOBBY, PRE_ROUND, ACTIVE, POST_ROUND, ENDED }
enum Team { NONE, RED, BLUE, GREEN }

signal game_initialized
signal match_state_changed(state: MatchState)
signal round_started(round: int)
signal round_ended(round: int)

var current_match_state: MatchState = MatchState.LOBBY
var network_manager: NetworkManager
var entity_system: EntitySystem

# ========================
# 👥 СИСТЕМА ИГРОКОВ
# ========================
signal player_connected(player: Player)
signal player_disconnected(player: Player)
signal player_spawned(player: Player)
signal player_died(player: Player, killer: Player)
signal player_team_changed(player: Player, old_team: Team, new_team: Team)

var players: Dictionary = {} # {id: Player}
var teams: Dictionary = {
    Team.RED: {"score": 0, "spawns": []},
    Team.BLUE: {"score": 0, "spawns": []}
}

# ========================
# 🔫 СИСТЕМА ОРУЖИЯ
# ========================
signal weapon_spawned(weapon: Weapon)
signal weapon_picked_up(weapon: Weapon, player: Player)

var weapons: Dictionary = {} # {id: Weapon}
var weapon_templates: Dictionary = {
    "rifle": {"damage": 30, "ammo": 150},
    "pistol": {"damage": 15, "ammo": 60}
}

# ========================
# 💰 ЭКОНОМИКА И МАГАЗИН
# ========================
signal currency_changed(player: Player, amount: int)
signal item_purchased(player: Player, item_id: String)

var shop_items: Dictionary = {
    "armor": {"price": 500, "effect": "add_armor"},
    "ammo_pack": {"price": 200, "effect": "add_ammo"}
}

# ========================
# 🌟 ВИЗУАЛЬНЫЕ ЭФФЕКТЫ
# ========================
signal effect_triggered(effect: String, position: Vector3)
signal post_process_changed(effect: String, params: Dictionary)

var vfx_manager: VFXManager = VFXManager.new()

# ========================
# 🕹 ОСНОВНЫЕ МЕТОДЫ
# ========================
func initialize() -> void:
    network_manager = NetworkManager.new()
    entity_system = EntitySystem.new()
    add_child(network_manager)
    add_child(entity_system)
    emit_signal("game_initialized")

func start_match() -> void:
    current_match_state = MatchState.ACTIVE
    emit_signal("match_state_changed", current_match_state)

func end_match(winner: Team = Team.NONE) -> void:
    current_match_state = MatchState.ENDED
    emit_signal("match_state_changed", current_match_state)

# ========================
# 👤 УПРАВЛЕНИЕ ИГРОКАМИ
# ========================
func spawn_player(player: Player, team: Team = Team.NONE) -> void:
    var spawn_point = _get_spawn_point(team)
    player.global_transform.origin = spawn_point
    player.stats.reset()
    emit_signal("player_spawned", player)

func respawn_player(player: Player, delay: float = 5.0) -> void:
    await get_tree().create_timer(delay).timeout
    spawn_player(player)

# ========================
# 🔫 УПРАВЛЕНИЕ ОРУЖИЕМ
# ========================
func give_weapon(player: Player, weapon_id: String) -> void:
    var weapon = Weapon.new(weapon_templates[weapon_id])
    player.weapon_system.add_weapon(weapon)
    weapons[weapon.id] = weapon

func remove_weapons(player: Player) -> void:
    player.weapon_system.clear_weapons()

# ========================
# 🛒 СИСТЕМА ПОКУПОК
# ========================
func open_shop(player: Player) -> void:
    player.hud.show_shop_ui(shop_items)

func purchase_item(player: Player, item_id: String) -> bool:
    if player.currency >= shop_items[item_id].price:
        player.currency -= shop_items[item_id].price
        _apply_item_effect(player, item_id)
        return true
    return false

# ========================
# 🌌 ВИЗУАЛЬНЫЕ ЭФФЕКТЫ
# ========================
func screen_shake(intensity: float, duration: float) -> void:
    vfx_manager.play_effect("screen_shake", {"intensity": intensity, "duration": duration})

func change_skybox(sky_name: String) -> void:
    vfx_manager.set_skybox(sky_name)

# ========================
# 🛠 СЛУЖЕБНЫЕ МЕТОДЫ
# ========================
func _get_spawn_point(team: Team) -> Vector3:
    var points = teams[team].spawns if team != Team.NONE else $SpawnPoints.get_children()
    return points[randi() % points.size()].global_transform.origin

func _apply_item_effect(player: Player, item_id: String) -> void:
    match shop_items[item_id].effect:
        "add_armor": player.stats.armor += 50
        "add_ammo": player.weapon_system.refill_ammo()
