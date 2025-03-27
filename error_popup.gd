extends PanelContainer

@onready var message_label = $MessageLabel

func set_message(text: String):
    message_label.text = text

func _on_close_button_pressed():
    queue_free()
