extends Control

@onready var title_label = $Panel/TitleLabel
@onready var message_label = $Panel/MessageLabel
@onready var timer = $Timer

enum STYLE {NORMAL, WARNING, ALERT, VICTORY}

func setup(title: String, message: String, duration: float, style: int):
    title_label.text = title
    message_label.text = message
    
    # Настройка стиля
    match style:
        STYLE.WARNING:
            $Panel.modulate = Color.YELLOW
        STYLE.ALERT:
            $Panel.modulate = Color.RED
        STYLE.VICTORY:
            $Panel.modulate = Color.GREEN
    
    if duration > 0:
        timer.start(duration)
    else:
        $CloseButton.visible = true

func _on_timer_timeout():
    queue_free()

func _on_close_button_pressed():
    queue_free()
