extends Node2D

func spaceStationPressed():
    Cope.gotoScene("SpaceStationMenu")


func startOnlineGame():
    var tmp = yield(Cope.gotoScene("Lobby"), "scene_ready")
    tmp.setAsServer(true)


func onlineCodeEntered(code):
    yield(Cope.gotoScene("Lobby"), "scene_ready").setAsServer(false, code)


func _on_Rules_pressed():
    Cope.gotoScene("Rules")

func _on_Profile_pressed():
    Cope.gotoScene("Profile")
