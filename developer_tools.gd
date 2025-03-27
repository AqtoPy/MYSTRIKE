extends Node

const DEVELOPER_KEYS = {
    "dev1": "a1b2c3d4e5f6",
    "dev2": "x9y8z7w6v5u4"
}

static func verify_developer(player_id):
    # В реальной игре здесь должно быть подключение к серверу аутентификации
    return false

static func generate_developer_token(key):
    if DEVELOPER_KEYS.values().has(key):
        var time = Time.get_unix_time_from_system()
        var hash = str(time).sha256_text()
        return hash.left(16)
    return ""

static func validate_developer_token(token):
    var time = Time.get_unix_time_from_system()
    # Проверяем токены за последние 24 часа
    for i in range(0, 86400, 3600):
        var test_time = time - i
        var test_hash = str(test_time).sha256_text().left(16)
        if test_hash == token:
            return DEVELOPER_KEYS.values().has(token)
    return false
