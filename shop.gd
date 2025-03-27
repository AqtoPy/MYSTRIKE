extends Control

@onready var skin_container = $SkinContainer
@onready var coins_label = $CoinsLabel
@onready var gems_label = $GemsLabel

var skins = {
    "default": {"name": "Standard", "price": 0, "gem_price": 0, "vip_only": false},
    "armored": {"name": "Armored", "price": 500, "gem_price": 0, "vip_only": false},
    "stealth": {"name": "Stealth", "price": 1000, "gem_price": 0, "vip_only": false},
    "golden": {"name": "Golden", "price": 0, "gem_price": 50, "vip_only": false},
    "vip": {"name": "VIP", "price": 0, "gem_price": 0, "vip_only": true}
}

func _ready():
    update_currency()
    populate_skins()

func update_currency():
    coins_label.text = "Coins: %d" % PlayerData.data["coins"]
    gems_label.text = "Gems: %d" % PlayerData.data["gems"]

func populate_skins():
    for skin_id in skins:
        var skin = skins[skin_id]
        var skin_card = preload("res://ui/skin_card.tscn").instantiate()
        
        skin_card.setup(
            skin_id,
            skin["name"],
            skin["price"],
            skin["gem_price"],
            skin["vip_only"],
            PlayerData.data["unlocked_skins"].has(skin_id),
            PlayerData.data["equipped_skin"] == skin_id,
            PlayerData.data["vip"]
        )
        
        skin_card.connect("purchase_requested", _on_purchase_requested)
        skin_card.connect("equip_requested", _on_equip_requested)
        
        skin_container.add_child(skin_card)

func _on_purchase_requested(skin_id, use_gems):
    var skin = skins[skin_id]
    if PlayerData.purchase_skin(skin_id, skin["gem_price"] if use_gems else skin["price"], use_gems):
        update_currency()
        # Обновляем все карточки
        for child in skin_container.get_children():
            child.queue_free()
        populate_skins()

func _on_equip_requested(skin_id):
    if PlayerData.data["unlocked_skins"].has(skin_id):
        PlayerData.data["equipped_skin"] = skin_id
        PlayerData.save_data()
        # Обновляем все карточки
        for child in skin_container.get_children():
            child.queue_free()
        populate_skins()

func _on_back_pressed():
    get_tree().change_scene_to_file("res://ui/main_menu.tscn")
