# player_interface.gd
class_name PlayerInterface
extends CharacterBody3D

# Обязательные свойства
@export var team: int = -1
@export var health: int = 100
@export var max_health: int = 100
var score: int = 0

# Обязательные методы
func respawn() -> void:
    health = max_health
    position = Vector3.ZERO
    rotation = Vector3.ZERO
    # Дополнительная логика возрождения

func add_score(amount: int) -> void:
    score += amount
    # Можно добавить визуальную обратную связь

func take_damage(amount: int, attacker: Node) -> void:
    health -= amount
    if health <= 0:
        die(attacker)

func die(attacker: Node) -> void:
    GameEvents.emit_signal("player_died", self, attacker)

# Дополнительные методы для API
func show_message(message: String, duration: float) -> void:
    # Реализация показа сообщения игроку
    pass

func play_sound(sound_path: String) -> void:
    # Реализация воспроизведения звука
    pass
