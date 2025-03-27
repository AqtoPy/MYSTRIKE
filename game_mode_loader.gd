extends Node

const CUSTOM_MODES_DIR = "user://game_modes"  # Папка для кастомных режимов

var builtin_modes = {
    "deathmatch": preload("res://game_modes/deathmatch.gd"),
    "team_deathmatch": preload("res://game_modes/team_deathmatch.gd"),
    "ctf": preload("res://game_modes/capture_the_flag.gd")
}

var custom_modes = {}

func _ready():
    # Создаем папку для кастомных режимов, если ее нет
    DirAccess.make_dir_recursive_absolute(CUSTOM_MODES_DIR)
    # Загружаем кастомные режимы
    load_custom_modes()

func load_custom_modes():
    custom_modes.clear()
    
    var dir = DirAccess.open(CUSTOM_MODES_DIR)
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if file_name.ends_with(".gd"):
                var mode_name = file_name.trim_suffix(".gd")
                var script = load(CUSTOM_MODES_DIR + "/" + file_name)
                if script and script.has_script_signal("mode_loaded"):
                    custom_modes[mode_name] = script
            file_name = dir.get_next()

func get_available_modes():
    var modes = {}
    modes.merge(builtin_modes)
    modes.merge(custom_modes)
    return modes

func get_mode_script(mode_name):
    var modes = get_available_modes()
    return modes.get(mode_name)
