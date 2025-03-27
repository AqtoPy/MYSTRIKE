extends Control

@onready var nickname_edit = $NicknameEdit
@onready var coins_label = $CoinsLabel
@onready var gems_label = $GemsLabel
@onready var vip_badge = $VipBadge
@onready var dev_badge = $DevBadge

func _ready():
    PlayerData.load_data()
    update_display()

func update_display():
    nickname_edit.text = PlayerData.data["nickname"]
    coins_label.text = "Coins: %d" % PlayerData.data["coins"]
    gems_label.text = "Gems: %d" % PlayerData.data["gems"]
    vip_badge.visible = PlayerData.data["vip"]
    dev_badge.visible = PlayerData.data["developer"]

func _on_nickname_edit_text_submitted(new_text):
    PlayerData.set_nickname(new_text)
    update_display()

func _on_create_server_pressed():
    get_tree().change_scene_to_file("res://ui/server_creation.tscn")

func _on_join_server_pressed():
    get_tree().change_scene_to_file("res://ui/server_browser.tscn")

func _on_shop_pressed():
    get_tree().change_scene_to_file("res://ui/shop.tscn")

func _on_quit_pressed():
    get_tree().quit()
