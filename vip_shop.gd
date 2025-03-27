extends Control

@onready var gems_label = $GemsLabel
@onready var purchase_button = $PurchaseButton
@onready var vip_perks = $VipPerks

func _ready():
    update_display()

func update_display():
    gems_label.text = "Gems: %d" % PlayerData.data["gems"]
    
    if PlayerData.data["vip"]:
        purchase_button.text = "VIP ACTIVE"
        purchase_button.disabled = true
        vip_perks.visible = true
    else:
        purchase_button.text = "BUY VIP (100 Gems)"
        purchase_button.disabled = PlayerData.data["gems"] < 100
        vip_perks.visible = false

func _on_purchase_pressed():
    if PlayerData.purchase_vip():
        update_display()
        show_popup("VIP Activated!", "You now have VIP status!", 3.0, "victory")

func show_popup(title, message, duration, style):
    var popup = preload("res://ui/popup.tscn").instantiate()
    popup.setup(title, message, duration, style)
    add_child(popup)

func _on_back_pressed():
      get_tree().change_scene_to_file("res://ui/shop.tscn")
