extends CharacterBody3D

@export var nickname = "Player"
@export var team = 0
@export var skin = "default"
@export var is_vip = false
@export var is_developer = false

@onready var nickname_label = $NicknameLabel
@onready var model = $CharacterModel

var health = 100
var max_health = 100
var speed = 5.0
var base_speed = 5.0

func _ready():
    update_appearance()
    apply_vip_effects()

func update_appearance():
    nickname_label.text = nickname
    model.set_skin(skin)
    
    if is_developer:
        nickname_label.add_theme_color_override("font_color", Color.GOLDENROD)
        nickname_label.text = "[DEV] " + nickname
    elif is_vip:
        nickname_label.add_theme_color_override("font_color", Color.GOLD)
        nickname_label.text = "[VIP] " + nickname
    
    if team == 0:
        model.set_team_color(Color.BLUE)
    else:
        model.set_team_color(Color.RED)

func apply_vip_effects():
    if is_vip:
        max_health = 150
        health = 150
        speed = base_speed * 1.2
        $VipParticles.emitting = true
    else:
        max_health = 100
        speed = base_speed
        $VipParticles.emitting = false

func take_damage(amount):
    health -= amount
    if health <= 0:
        die()

func die():
    # Логика смерти
    pass
