# game_mode_manager.gd (добавить в autoload)
extends Node
class_name GameModeManager

const MODES_DIR = "res://game/modes/"

var current_mode: GameModeAPI = null
var registered_modes = {}

func _ready():
    register_builtin_modes()

func register_builtin_modes():
    register_mode("deathmatch", load(MODES_DIR + "deathmatch.gd"))
    register_mode("team_deathmatch", load(MODES_DIR + "team_deathmatch.gd"))
    register_mode("ctf", load(MODES_DIR + "capture_the_flag.gd"))

func register_mode(mode_name: String, mode_script: GDScript) -> bool:
    if !_validate_mode_script(mode_script):
        push_error("Не удалось зарегистрировать режим: невалидный скрипт")
        return false
    
    registered_modes[mode_name] = mode_script
    return true

func _validate_mode_script(script: GDScript) -> bool:
    var source = script.source_code
    return (
        "extends GameModeAPI" in source and
        "func initialize()" in source and
        "func cleanup()" in source and
        "signal mode_initialized" in source
    )

func load_mode(mode_name: String) -> bool:
    if !registered_modes.has(mode_name):
        push_error("Режим не зарегистрирован: " + mode_name)
        return false
    
    if current_mode:
        current_mode.cleanup()
        current_mode.queue_free()
    
    current_mode = registered_modes[mode_name].new()
    add_child(current_mode)
    
    if !current_mode.initialize():
        push_error("Ошибка инициализации режима")
        current_mode = null
        return false
    
    return true

func get_current_mode() -> GameModeAPI:
    return current_mode

func is_mode_active() -> bool:
    return current_mode != null
