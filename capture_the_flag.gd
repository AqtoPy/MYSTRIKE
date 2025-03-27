extends BaseGameMode

class_name CaptureTheFlagMode

var flags = []
var flag_return_time = 30.0

func _init():
    mode_name = "Capture The Flag"
    team_based = true
    score_to_win = 3

func start_mode():
    super.start_mode()
    spawn_flags()
    start_flag_return_timers()

func spawn_flags():
    # Удаляем старые флаги
    for flag in flags:
        flag.queue_free()
    flags.clear()
    
    # Спавним флаги для каждой команды
    for team in teams:
        var flag = preload("res://objects/flag.tscn").instantiate()
        flag.team = team
        flag.position = get_flag_spawn_position(team)
        get_tree().current_scene.add_child(flag)
        flags.append(flag)
        
        flag.flag_picked_up.connect(_on_flag_picked_up)
        flag.flag_dropped.connect(_on_flag_dropped)
        flag.flag_captured.connect(_on_flag_captured)

func get_flag_spawn_position(team):
    var spawns = get_tree().get_nodes_in_group("team_%d_flag_spawn" % team)
    if spawns.size() > 0:
        return spawns[0].global_position
    return Vector3.ZERO

func _on_flag_picked_up(flag, player):
    if player.team != flag.team:
        GameEvents.show_popup("Flag Taken!", "%s took %s flag!" % [
            player.nickname, 
            teams[flag.team]["name"]
        ])

func _on_flag_dropped(flag, position):
    GameEvents.show_popup("Flag Dropped!", "%s flag was dropped!" % teams[flag.team]["name"])

func _on_flag_captured(flag, player):
    if player.team != flag.team:
        teams[player.team]["score"] += 1
        GameEvents.show_popup("Flag Captured!", "%s scored for %s!" % [
            player.nickname,
            teams[player.team]["name"]
        ], 5.0, GameEvents.PopupStyle.VICTORY)
        
        check_win_condition()

func check_win_condition():
    for team in teams:
        if teams[team]["score"] >= score_to_win:
            end_mode(team)
            return

func start_flag_return_timers():
    for flag in flags:
        if flag.is_held():
            start_flag_return_timer(flag)

func start_flag_return_timer(flag):
    await get_tree().create_timer(flag_return_time).timeout
    if flag and not flag.is_held() and not flag.is_at_base():
        flag.return_to_base()
        GameEvents.show_popup("Flag Returned", "%s flag returned to base!" % teams[flag.team]["name"])
