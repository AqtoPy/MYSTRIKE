class_name GameEvents
extends Node

enum PopupStyle {NORMAL, WARNING, ALERT, VICTORY}

static func show_popup(title: String, message: String, duration: float = 3.0, style: PopupStyle = PopupStyle.NORMAL):
    var popup = preload("res://ui/popup.tscn").instantiate()
    popup.setup(title, message, duration, style)
    get_tree().root.add_child(popup)

static func update_scoreboard():
    if get_tree().root.has_node("GameServer"):
        get_tree().root.get_node("GameServer").update_scoreboard()

static func log_event(message: String):
    print("[GameEvent] ", message)
    if get_tree().root.has_node("GameServer"):
        get_tree().root.get_node("GameServer").log_event.rpc(message)
