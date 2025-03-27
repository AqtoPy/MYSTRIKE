class_name Player
extends CharacterBody3D

# Настройки движения
@export var walk_speed := 5.0
@export var sprint_speed := 8.0
@export var jump_velocity := 4.5
@export var mouse_sensitivity := 0.002

# Сетевые параметры
@export var sync_rate := 0.1  # Секунд между синхронизациями

var current_speed := walk_speed
var health := 100
var score := 0
var team := -1
var is_ready := false

@onready var camera := $Camera3D
@onready var model := $Model

func _enter_tree():
    if multiplayer.get_unique_id() == get_multiplayer_authority():
        camera.current = true
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
    if not multiplayer.is_server(): return
    
    # Движение
    var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
    var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    
    if direction:
        velocity.x = direction.x * current_speed
        velocity.z = direction.z * current_speed
    else:
        velocity.x = move_toward(velocity.x, 0, current_speed)
        velocity.z = move_toward(velocity.z, 0, current_speed)
    
    # Гравитация
    if not is_on_floor():
        velocity.y -= gravity * delta
    
    move_and_slide()
    
    # Синхронизация
    sync_timer += delta
    if sync_timer >= sync_rate:
        sync_timer = 0.0
        rpc("_sync_state", position, rotation, velocity)

@rpc("any_peer")
func take_damage(amount: int, attacker_id: int):
    if not multiplayer.is_server(): return
    
    health -= amount
    if health <= 0:
        die(attacker_id)

func die(attacker_id: int):
    health = 0
    rpc("_on_death", attacker_id)
    GameServer.player_died.emit(self, get_player_by_id(attacker_id))

@rpc("call_local")
func respawn():
    health = 100
    position = Vector3.ZERO
