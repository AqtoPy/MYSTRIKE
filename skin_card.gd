extends Control

signal purchase_requested(skin_id, use_gems)
signal equip_requested(skin_id)

var skin_id: String

func setup(id: String, name: String, price: int, gem_price: int, vip_only: bool, unlocked: bool, equipped: bool, has_vip: bool):
    skin_id = id
    
    $NameLabel.text = name
    
    if vip_only:
        $PriceLabel.text = "VIP ONLY"
        $PurchaseButton.visible = has_vip and not unlocked
    elif gem_price > 0:
        $PriceLabel.text = "%d Gems" % gem_price
        $PurchaseButton.visible = not unlocked
    else:
        $PriceLabel.text = "%d Coins" % price
        $PurchaseButton.visible = not unlocked
    
    $EquipButton.visible = unlocked
    $EquipButton.disabled = equipped
    
    if equipped:
        $EquipButton.text = "EQUIPPED"
    else:
        $EquipButton.text = "EQUIP"

func _on_purchase_button_pressed():
    emit_signal("purchase_requested", skin_id, $PriceLabel.text.contains("Gems"))

func _on_equip_button_pressed():
    emit_signal("equip_requested", skin_id)
