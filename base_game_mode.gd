class_name BaseGameMode
extends Node

signal mode_started()
signal mode_ended(winner)
signal player_spawned(player)
signal player_eliminated(player)

var mode_name = "Base Mode"
var team_based = false
var score_to_win = 100

var players = []
var teams = {}

func start_mode():
    emit_signal("mode_started")
    setup_teams()
    spawn_all_players()

func end_mode(winner):
    emit_signal("mode_ended", winner)

func setup_teams():
    if team_based:
        teams = {
            0: {"name": "Red Team", "score": 0, "color": Color.RED},
            1: {"name": "Blue Team", "score": 0, "color": Color.BLUE}
        }

func spawn_all_players():
    for player in players:
        spawn_player(player)

func spawn_player(player):
    var spawn_point = get_spawn_point(player)
    if spawn_point:
        player.global_transform = spawn_point.global_transform
        emit_signal("player_spawned", player)

func get_spawn_point(player):
    var spawn_points = get_tree().get_nodes_in_group("spawn_points")
    if team_based:
        spawn_points = get_tree().get_nodes_in_group("team_%d_spawns" % player.team)
    
    if spawn_points.size() > 0:
        return spawn_points[randi() % spawn_points.size()]
    return null

func register_player(player):
    if not players.has(player):
        players.append(player)
        
        if team_based:
            assign_team(player)

func assign_team(player):
    # Простая балансировка команд
    var team0_count = 0
    var team1_count = 0
    
    for p in players:
        if p.team == 0:
            team0_count += 1
        elif p.team == 1:
            team1_count += 1
    
    player.team = 0 if team0_count <= team1_count else 1
