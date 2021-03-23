extends Node2D

func spaceStationPressed():
    Cope.gotoScene("SpaceStationMenu")


func startOnlineGame():
    Cope.gotoScene("Lobby")
    Game.startServer()


func onlineCodeEntered(code):
    Cope.gotoScene("Lobby")
    Game.startClient(code)


func _on_Rules_pressed():
    Cope.gotoScene("Rules")

func _on_Profile_pressed():
    Cope.gotoScene("Profile")


export var _name: String

func _ready():
    Game.player.name = _name