extends TextureRect

export var MAX_PLAYERS = 20
export var SERVER_IP = "10.49.176.109"
var code = SERVER_IP
export var readyIcon: Texture
export var notReadyIcon: Texture

onready var playerList = $VBoxContainer/PlayerList
# onready var statusNode = $Label4

# Player info, associate ID to data
var everyonesData = {}
var players_done = []
# Info we send to other players
var myData = {name = Game.player.name, ready = false}



# If the parameter is false, this is a client lobby.
func setAsServer(isServer, code=null):
    if isServer:
        # Initializing as a server, listening on the given port, with a given maximum number of peers:
        Game.server = NetworkedMultiplayerENet.new()
        Game.server.create_server(Game.port, MAX_PLAYERS)
        get_tree().network_peer = Game.server
        $Code.text = SERVER_IP
        $Status.text = "Hosting"
        Cope.popup("GENIUS", "You genius you")
    else:
        assert(code)
        assert(code.length())
        # Initializing as a client, connecting to a given IP and port:
        Game.player.client = NetworkedMultiplayerENet.new()
        # Game.player.client.create_client(code, Game.port)
        Game.player.client.create_client(SERVER_IP, Game.port)
        get_tree().network_peer = Game.player.client
        $Code.text = code



# Typical lobby implementation; imagine this being in /root/lobby.
func _ready():
    get_tree().connect("network_peer_connected", self, "_player_connected")
    get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
    get_tree().connect("connected_to_server", self, "_connected_ok")
    get_tree().connect("connection_failed", self, "_connected_fail")
    get_tree().connect("server_disconnected", self, "_server_disconnected")


# Called on both clients and server when a peer connects. Send my info to it.
func _player_connected(id):
    rpc_id(id, "register_player", myData)


func _player_disconnected(id):
    everyonesData.erase(id) # Erase player from info.
    $Status.text = "Disconnected"


func _connected_ok():
    $Status.text = "Connected Successfully"
    # if not get_tree().is_network_server():
        # pass # Only called on clients, not server. Will go unused; not useful here.


func _server_disconnected():
    $Status.text = "Disconnected"
    if not get_tree().is_network_server():
        # Server kicked us; show error and abort.
        Cope.popup("Disconnected", "Whoops! You've been disconnected from the game.")


func _connected_fail():
    $Status.text = "Can't connect to game"
    # Could not even connect to server; abort.


remote func register_player(data):
    # Get the id of the RPC sender.
    var id = get_tree().get_rpc_sender_id()
    # Store the info
    everyonesData[id] = data

    $Code.text = code

    updatePlayerList()


func updatePlayerList():
    playerList.clear()
    for i in everyonesData.values():
        playerList.add_item(i["name"], readyIcon if i["ready"] else notReadyIcon)


func startGame():
    rpc("pre_configure_game")


remote func pre_configure_game():
    get_tree().set_pause(true) # Pre-pause
    # The rest is the same as in the code in the previous section (look above)
    # var selfPeerID = get_tree().get_network_unique_id()

    # Load world
    var world = load("res://SpaceStationMenu.tscn").instance()
    get_node("/root").add_child(world)
    get_tree().set_current_scene(world)

    if get_tree().is_network_server():
        rset("Cope.useableShips", Cope.useableShips)
        rpc("Cope.player.init", Cope.useableShips)

    # Cope.gotoScene("SpaceStationMenu")

    # Load my player
    # var my_player = preload("res://player.tscn").instance()
    # my_player.set_name(str(selfPeerID))
    # my_player.set_network_master(selfPeerID) # Will be explained later
    # get_node("/root/world/players").add_child(my_player)

    # Load other players
    # for p in player_info:
    #     var player = preload("res://player.tscn").instance()
    #     player.set_name(str(p))
    #     player.set_network_master(p) # Will be explained later
    #     get_node("/root/world/players").add_child(player)

    # Tell server (remember, server is always ID=1) that this peer is done pre-configuring.
    # The server can call get_tree().get_rpc_sender_id() to find out who said they were done.
    rpc_id(1, "done_preconfiguring")


remote func done_preconfiguring():
    var who = get_tree().get_rpc_sender_id()
    # Here are some checks you can do, for example
    assert(get_tree().is_network_server())
    assert(who in everyonesData) # Exists
    assert(not who in players_done) # Was not added yet

    players_done.append(who)

    if players_done.size() == everyonesData.size():
        rpc("post_configure_game")


remote func post_configure_game():
    # Only the server is allowed to tell a client to unpause
    if get_tree().get_rpc_sender_id() == 1:
        get_tree().set_pause(false)
        # Game starts now!


remotesync func playerReady(isReady):
    everyonesData[get_tree().get_rpc_sender_id()]['ready'] = isReady

    if get_tree().is_network_server():
        for i in everyonesData.values():
            if not i["ready"]:
                return
        startGame()


func _on_StartButton_pressed():
    rpc("playerReady", true)



# git add .; git commit -m "minor networking changes"; git push https://smartycope%40gmail.com:NoPorn17\!@github.com/smartycope/Submission.git master