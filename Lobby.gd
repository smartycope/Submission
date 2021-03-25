extends TextureRect

# var code = SERVER_IP
export var readyIcon: Texture
export var notReadyIcon: Texture

onready var playerList = $VBoxContainer/PlayerList


# Typical lobby implementation; imagine this being in /root/lobby.
func _ready():
    get_tree().connect("network_peer_connected", self, "_player_connected")
    get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
    get_tree().connect("connected_to_server", self, "_connected_ok")
    get_tree().connect("connection_failed", self, "_connected_fail")
    get_tree().connect("server_disconnected", self, "_server_disconnected")
    Game.player.status = "Connecting..."
    # Game.status = "Hosting"
    updateStatus()
    updatePlayerList()

    if get_tree().is_network_server():
        $Code.text = Game.myIP
    else:
        $Code.text = Game.clientCode


# Called on both clients and server when a peer connects. Send my info to it.
func _player_connected(id):
    rpc_id(id, "register_player", Game.player.getNetworkingData())


func updateStatus():
    if get_tree().is_network_server():
        $Status.text = Game.status
    else:
        $Status.text = Game.player.status


func _player_disconnected(id):
    Game.player.status = "Disconnected"
    # Game.playerDisconnected(id)
    Game.allPlayerData.erase(id) # Erase player from info.
    updateStatus()
    updatePlayerList()


func _connected_ok():
    Game.player.status = "Connected Successfully"
    updateStatus()
    updatePlayerList()
    # if not get_tree().is_network_server():
        # pass # Only called on clients, not server. Will go unused; not useful here.


func _server_disconnected():
    # if not get_tree().is_network_server():
    Game.player.status = "Disconnected"
    Cope.popup("Disconnected", "Whoops! You've been disconnected from the game.")
    updateStatus()
    updatePlayerList()


func _connected_fail():
    Game.player.status = "Can't connect to game"
    updateStatus()


remote func register_player(data):
    # Get the id of the RPC sender.
    var id = get_tree().get_rpc_sender_id()
    if id == 0:
        id = get_tree().get_network_unique_id()
    # Store the info
    Game.allPlayerData[id] = data
    # $Code.text = code
    print("player registered", data, "\nMy ID: ", get_tree().get_network_unique_id(), "\nHis ID: ", get_tree().get_rpc_sender_id())

    updatePlayerList()


func updatePlayerList():
    playerList.clear()
    for i in Game.allPlayerData.values():
        playerList.add_item(i["name"], readyIcon if i["ready"] else notReadyIcon)


func startGame():
    rpc("pre_configure_game")


remotesync func pre_configure_game():
    print('starting preconfiguring')
    assert(get_tree().get_rpc_sender_id() == 1)
    get_tree().set_pause(true) # Pre-pause
    # The rest is the same as in the code in the previous section (look above)
    # var selfPeerID = get_tree().get_network_unique_id()

    # Load world
    var world = load("res://SpaceStationMenu.tscn").instance()
    get_node("/root").add_child(world)
    get_tree().set_current_scene(world)

    # var world = yield(Cope.gotoScene("SpaceStationMenu", true), "scene_ready")

    if get_tree().is_network_server():
        rset("Game.useableShips", Game.useableShips)
        rpc("Game.player.init", Game.useableShips)
        Game.playerTurnOrder = Game.allPlayerData.keys()
        rset("Game.playerTurnOrder", Game.playerTurnOrder)

    # Cope.gotoScene("SpaceStationMenu")

    # Load my player
    var myID = get_tree().get_network_unique_id()
    Game.player.id = myID

    Game.currentTurnName = Game.allPlayerData[1]['name']

    print("almost done preconfiguring and data is: ", Game.allPlayerData)

    world.updateTurn()

    # var my_player = preload("res://player.tscn").instance()
    # my_player.set_name(str(selfPeerID))
    # Game.player.set_network_master(selfPeerID) # Will be explained later
    # get_node("/root/world/players").add_child(my_player)

    # Load other players
    # for p in Game.allPlayerData:
        # var player = preload("res://player.tscn").instance()
        # player.set_name(str(p))
        # var player =
        # player.set_network_master(p) # Will be explained later
        # get_node("/root/world/players").add_child(player)

    # Tell server (remember, server is always ID=1) that this peer is done pre-configuring.
    # The server can call get_tree().get_rpc_sender_id() to find out who said they were done.
    if not get_tree().is_network_server():
        rpc_id(1, "done_preconfiguring")
    else:
        post_configure_game()


remote func done_preconfiguring():
    var who = get_tree().get_rpc_sender_id()
    print(who, " is done_preconfiguring!")
    # Here are some checks you can do, for example
    assert(get_tree().is_network_server())
    assert(who in Game.allPlayerData) # Exists
    assert(not who in Game.playersDoneLoading) # Was not added yet

    Game.playersDoneLoading.append(who)

    if Game.playersDoneLoading.size() == Game.allPlayerData.size():
        rpc("post_configure_game")


remote func post_configure_game():
    print('post configuring')
    # Only the server is allowed to tell a client to unpause
    if get_tree().get_rpc_sender_id() == 1:
        get_tree().set_pause(false)
        print("pause is now set to: ", get_tree().paused)
        # if is_instance_valid(get_tree().get_root().get_node('Lobby')):
        #     get_tree().get_root().get_node('Lobby').queue_free()

        # Game starts now!


remotesync func playerReady(isReady):
    print("data: ", Game.allPlayerData)
    Game.allPlayerData[get_tree().get_rpc_sender_id()]['ready'] = isReady

    updateStatus()
    updatePlayerList()

    if get_tree().is_network_server():
        for i in Game.allPlayerData.values():
            if not i["ready"]:
                return
        startGame()


func _on_StartButton_pressed():
    rpc("playerReady", true)






































# cd ~/hello/Godot/Submission/; git add .; git commit -m "minor networking changes"; git push https://smartycope%40gmail.com:NoPorn17\!@github.com/smartycope/Submission.git master
