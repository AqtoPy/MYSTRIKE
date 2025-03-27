extends Node3D

@onready var mesh = $MeshInstance3D
@onready var particles = $VipParticles

func set_skin(skin_id: String):
    SkinManager.apply_skin(self, skin_id)

func set_team_color(color: Color):
    if mesh.material_override:
        mesh.material_override.albedo_color = color

func play_animation(anim_name: String):
    # Здесь будет логика анимаций
    pass
