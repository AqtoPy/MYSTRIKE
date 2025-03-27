extends Node

var skins = {
    "default": {
        "mesh": preload("res://models/characters/default_mesh.tres"),
        "material": preload("res://models/characters/default_material.tres")
    },
    "armored": {
        "mesh": preload("res://models/characters/armored_mesh.tres"),
        "material": preload("res://models/characters/armored_material.tres")
    },
    "vip": {
        "mesh": preload("res://models/characters/vip_mesh.tres"),
        "material": preload("res://models/characters/vip_material.tres"),
        "vip_only": true
    }
}

func get_skin(skin_id: String):
    if skins.has(skin_id):
        return skins[skin_id]
    return skins["default"]

func apply_skin(character_node: Node, skin_id: String):
    var skin_data = get_skin(skin_id)
    
    if skin_data:
        character_node.get_node("MeshInstance3D").mesh = skin_data["mesh"]
        character_node.get_node("MeshInstance3D").material_override = skin_data["material"]
        
        if skin_id == "vip":
            character_node.get_node("VipParticles").emitting = true
        else:
            character_node.get_node("VipParticles").emitting = false
