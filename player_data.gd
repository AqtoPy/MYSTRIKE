extends Node

const SECRET_KEY = "xJ8#kL9!pZ2@mW5$"  # Ключ шифрования
const SAVE_PATH = "user://player_data.bin"

var data = {
    "nickname": "Player",
    "coins": 1000,
    "gems": 50,
    "vip": false,
    "developer": false,
    "unlocked_skins": ["default"],
    "equipped_skin": "default",
    "settings": {}
}

func _ready():
    load_data()

func save_data():
    var file = FileAccess.open_encrypted_with_pass(SAVE_PATH, FileAccess.WRITE, SECRET_KEY)
    file.store_var(data)
    file.close()

func load_data():
    if FileAccess.file_exists(SAVE_PATH):
        var file = FileAccess.open_encrypted_with_pass(SAVE_PATH, FileAccess.READ, SECRET_KEY)
        var loaded = file.get_var()
        if loaded is Dictionary:
            data = loaded
        file.close()

func unlock_skin(skin_name):
    if not data["unlocked_skins"].has(skin_name):
        data["unlocked_skins"].append(skin_name)
        save_data()

func purchase_vip():
    if not data["vip"] and data["gems"] >= 100:
        data["gems"] -= 100
        data["vip"] = true
        save_data()
        return true
    return false

func purchase_skin(skin_name, price, is_gem):
    if data["unlocked_skins"].has(skin_name):
        return false
        
    if (is_gem and data["gems"] >= price) or (not is_gem and data["coins"] >= price):
        if is_gem:
            data["gems"] -= price
        else:
            data["coins"] -= price
        unlock_skin(skin_name)
        return true
    return false

func set_nickname(new_nick):
    if new_nick.length() > 0 and new_nick.length() <= 16:
        data["nickname"] = new_nick
        save_data()
        return true
    return false

func set_developer_status(active):
    # Только для специальных сборок
    if OS.has_feature("developer"):
        data["developer"] = active
        save_data()
        return true
    return false
