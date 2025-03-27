extends GameModeAPI
class_name TDMMode

@export var kill_score: int = 1
@export var score_limit: int = 50
@export var round_time_limit: int = 600 # 10 минут

var team_scores = {
    Team.RED: 0,
    Team.BLUE: 0
}

func _init():
    mode_name = "Team Deathmatch"
    mode_description = "Уничтожьте команду противника!"
    team_based = true
    round_based = true
    score_to_win = score_limit

func initialize():
    super.initialize()
    setup_ui()

func setup_ui():
    # Настройка интерфейса для TDM
    for player in players.values():
        player.hud.setup_tdm_ui(team_scores[Team.RED], team_scores[Team.BLUE])

func start_round(round_num: int):
    super.start_round(round_num)
    
    # Сброс статистики
    for player in players.values():
        player.reset_stats()
    
    # Спавн игроков
    for player in players.values():
        spawn_player(player, player.team)
    
    # Старт таймера раунда
    start_timer(round_time_limit)
    
    show_message_all("Раунд %d начался!" % round_num, 3.0)

func on_player_killed(victim: Player, killer: Player):
    if killer and killer != victim and killer.team != victim.team:
        # Начисление очков команде
        team_scores[killer.team] += kill_score
        
        # Обновление UI
        for player in players.values():
            player.hud.update_scores(team_scores[Team.RED], team_scores[Team.BLUE])
        
        # Проверка победы
        if team_scores[killer.team] >= score_limit:
            end_round(killer.team)
    
    # Возрождение через 5 секунд
    respawn_player(victim, 5.0)

func end_round(winning_team: Team):
    # Выдать награды
    for player in get_players_in_team(winning_team):
        player.add_score(100)
        player.add_currency(50)
    
    show_message_all("Команда %s победила!" % Team.keys()[winning_team], 5.0)
    
    # Переход к следующему раунду
    await get_tree().create_timer(5.0).timeout
    start_round(current_round + 1)

func on_timer_end():
    # Время вышло, определяем победителя по очкам
    if team_scores[Team.RED] > team_scores[Team.BLUE]:
        end_round(Team.RED)
    elif team_scores[Team.BLUE] > team_scores[Team.RED]:
        end_round(Team.BLUE)
    else:
        # Ничья
        end_round(Team.NONE)

## Вспомогательные классы

class TeamData:
    var team: Team
    var color: Color
    var spawn_points: Array[Vector3]
    var score: int = 0
    
    func _init(t: Team, c: Color, sp: Array):
        team = t
        color = c
        spawn_points = sp
    
    func get_random_spawn_point() -> Vector3:
        return spawn_points[randi() % spawn_points.size()]

class WeaponManager:
    static func create_weapon(weapon_name: String) -> Weapon:
        var weapon = Weapon.new()
        weapon.type = weapon_name
        weapon.ammo = WeaponData.get_max_ammo(weapon_name)
        return weapon

class WeaponData:
    static func get_max_ammo(weapon_type: String) -> int:
        match weapon_type:
            "pistol": return 60
            "rifle": return 180
            "shotgun": return 30
            _: return 0
