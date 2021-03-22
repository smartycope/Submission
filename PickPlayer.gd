extends PopupMenu


func _ready():
    add_item("Which player would you like to attack?")
    add_item('\n')
    for p in Game.players.slice(1, -1):
        add_check_item(p.name)


func attackPlayer(index):
    Game.attack(Game.getPlayerByName(get_item_text(index)))
