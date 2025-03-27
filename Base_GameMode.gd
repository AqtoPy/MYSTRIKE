class_name GameMode
extends Node

# Сигналы режима
signal mode_initialized()
signal round_started(round_number: int)
signal round_ended(winner_team: int)
signal match_ended(winner_team: int)

# Настройки режима
@export var mode_name := "Базовый режим"
@export var mode_description := "Описание режима"
@export var team_based := false
@export var round_based := false
@export var score_to_win := 100

var players := {}
var teams := {
    0: {"name": "Команда 1", "score": 0, "color": Color.RED},
    1: {"name": "Команда 2", "score": 0, "color": Color.BLUE}
}

func initialize():
    """Инициализация режима"""
    emit_signal("mode_initialized")
    setup_players()
    
    if round_based:
        start_round(1)
    else:
        start_match()

func start_match():
    """Начало матча"""
    spawn_all_players()

func end_match(winner_team: int):
    """Завершение матча"""
    emit_signal("match_ended", winner_team)
    cleanup()

func start_round(round_number: int):
    """Начало раунда"""
    reset_round()
    emit_signal("round_started", round_number)
    spawn_all_players()

func end_round(winner_team: int):
    """Завершение раунда"""
    emit_signal("round_ended", winner_team)
    
    if round_based:
        await get_tree().create_timer(5.0).timeout
        start_round(current_round + 1)

func spawn_all_players():
    """Спавн всех игроков"""
    for player in players.values():
        spawn_player(player)

func spawn_player(player: Node):
    """Спавн конкретного игрока"""
    pass

func cleanup():
    """Очистка ресурсов"""
    pass
