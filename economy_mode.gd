extends GameModeAPI

var capture_zones = []
var shop_items = {
    "pistol": 100,
    "rifle": 300,
    "armor": 200
}

func initialize_mode():
    mode_name = "Economic War"
    mode_description = "Capture zones to earn money and buy weapons"
    mode_hint = "Capture zones to earn $ | Press B to buy weapons"
    
    allow_weapons = false  # Оружие только через покупку
    allow_purchases = true
    team_based = true
    
    # Настройка магазина
    for item in shop_items:
        add_shop_item(item, shop_items[item])
    
    # Создание зон захвата
    create_capture_zones()

func create_capture_zones():
    var zone_positions = [
        Vector3(0, 0, 50),
        Vector3(100, 0, -50),
        Vector3(-100, 0, -50)
    ]
    
    for pos in zone_positions:
        var zone = create_zone("Money Zone", pos, Vector3(10, 5, 10), 5)
        zone.connect("player_entered", _on_zone_entered)
        zone.connect("player_exited", _on_zone_exited)
        capture_zones.append(zone)

func _on_zone_entered(player, zone):
    if player.team == zone.controlled_by:
        return
        
    show_popup("Zone Captured", "+$%d per second!" % zone.earn_rate, 2.0, "info")
    player.zone_timer = Timer.new()
    player.add_child(player.zone_timer)
    player.zone_timer.start(1.0)
    player.zone_timer.timeout.connect(_on_zone_earn.bind(player, zone))

func _on_zone_earn(player, zone):
    give_currency(player, zone.earn_rate)

func _on_zone_exited(player, zone):
    if player.has_node("zone_timer"):
        player.zone_timer.queue_free()

func _on_item_purchased(player, item):
    match item:
        "pistol":
            give_weapon(player, "pistol")
        "rifle":
            give_weapon(player, "rifle")
        "armor":
            player.health += 50
