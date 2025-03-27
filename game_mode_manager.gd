extends Node

var current_mode = null
var available_modes = {
    "deathmatch": preload("res://game_modes/deathmatch.gd"),
    "team_deathmatch": preload("res://game_modes/team_deathmatch.gd"),
    "ctf": preload("res://game_modes/capture_the_flag.gd")
}

func load_mode(mode_name: String):
    if available_modes.has(mode_name):
        if current_mode:
            current_mode.queue_free()
        
        current_mode = available_modes[mode_name].new()
        add_child(current_mode)
        return current_mode
    return null

func create_custom_mode(script_path: String):
    if FileAccess.file_exists(script_path):
        var script = load(script_path)
        if script is GDScript:
            if current_mode:
                current_mode.queue_free()
            
            current_mode = script.new()
            add_child(current_mode)
            return current_mode
    return null
