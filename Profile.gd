extends TextureRect


func _ready():
    $Name.text = Game.player.name


func setName(name):
    Game.player.name = name
    Cope.setJSONvalue("settings.json", "name", name)


func setPort(value):
    Game.port = value


func setIcon(path):
    var icon = load(path)
    # Best line of code *ever*
    $Icon.icon = icon
    Game.player.icon = icon
