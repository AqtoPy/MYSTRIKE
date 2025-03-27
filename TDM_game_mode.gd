class_name DeathmatchMode
extends GameMode

@export var kill_score := 1
@export var respawn_delay := 3.0

func _init():
    mode_name = "Deathmatch"
    mode_description = "Убейте всех противников!"
    team_based = false
    round_based = false
    score_to_win = 20

func initialize():
    super.initialize()
    GameServer.player_died.connect(_on_player_died)

func _on_player_died(victim: Node, killer: Node):
    if killer != null and killer != victim:
        killer.score += kill_score
        
        if killer.score >= score_to_win:
            end_match(killer)
    
    await get_tree().create_timer(respawn_delay).timeout
    spawn_player(victim)

func spawn_player(player: Node):
    var spawn_points = get_tree().get_nodes_in_group("spawn_points")
    var spawn = spawn_points.pick_random()
    player.global_transform = spawn.global_transform
    player.respawn()
