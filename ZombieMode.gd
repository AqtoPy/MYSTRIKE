# Пример создания кастомного режима
class_name ZombieMode
extends GameModeAPI

func _init():
    mode_name = "Zombie Infection"
    mode_description = "Один становится зомби, остальные выживают"
    team_based = true
    round_based = true
    score_to_win = 10

func initialize():
    super.initialize()
    select_initial_zombie()

func select_initial_zombie():
    var players = get_players()
    if !players.is_empty():
        var zombie = players.pick_random()
        change_player_team(zombie, 1) # 1 - команда зомби
        zombie.make_zombie()

func on_player_death(player, killer):
    if player.team == 0: # Человек
        respawn_player_as_zombie(player)
    else: # Зомби
        respawn_player(player, 10.0)

func respawn_player_as_zombie(player):
    change_player_team(player, 1)
    player.make_zombie()
    respawn_player(player, 3.0)
