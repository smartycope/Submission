extends Node

var nullShip = Ship.new("You've run out of ships", load("res://nullShipIcon.png"), -1, "This is the phantom null ship. Please dispose of it promptly.", -1, -1, -1, -1, -1, -1, 'This ship is here because you\'ve run out of ships', "This is a naughty ship.")

var Ai = load("res://AI.gd")

var myIP = IP.get_local_addresses()[0]

var turn = 1
var status = 'Hosting'
var port = 6667

var allPlayerData = {}
var playersDoneLoading = []

# players is now a list of names
var players = []
var player = null # The current player
var turnIndex = 0 # The index of the player who's turn it currently is
# const startingDeckSize = 10
var currentTurnName = 'root'

var startingDeck = []
const maxShipTypes = 10

const MAX_PLAYERS = 20

var clientCode = myIP

var playerTurnOrder = []

var ships = []
var basicShips = []
var useableShips = []

var mode

var server = null

enum {AI, SERVER, CLIENT}


func getShip(name, regular=true):
    for i in ships if regular else basicShips:
        if i.name == name:
            return i
    return nullShip


func _ready():
    nullShip.used = true

    #* Load all the ships
    for i in Cope.getJSON('ships.json')["Regular"]:
        ships.append(Ship.new(i))
    for i in Cope.getJSON('ships.json')["Basic"]:
        basicShips.append(Ship.new(i))

    #* Load (and set) all their icons
    for i in ships:
        i.icon = load(i.icon)
    for i in basicShips:
        i.icon = load(i.icon)

    #* Fill the useableShips with random ships
    for i in maxShipTypes:
        useableShips.append(Ship.new(ships[int(rand_range(0, ships.size()))].serialize()))

    #* Add basic money and defense and attack ships
    useableShips += basicShips

    for i in 7:
        startingDeck.append(getShip("Old Gaffer"))
    for i in 3:
        startingDeck.append(getShip("Sheild Ship - Basic"))

    var Player = load("res://Player.gd")

    players.append(Player.new(Cope.getJSONvalue("settings.json", "name"), startingDeck))
    player = players[0]
    players.append(Ai.new(Ai.EASY))


remote func endTurn():
    turn += 1

    # if get_tree().is_network_server():
    turnIndex = turn - 1
    turnIndex = wrapi(turnIndex, 0, players.size())

    player.endTurn()

    rpc("itsIDsTurn", playerTurnOrder[turnIndex])


        # players[turnIndex].takeTurn(false) # This parameter must change eventually
    # rpc


remotesync func itsIDsTurn(id):
    currentTurnName = allPlayerData[id]['name']
    if get_tree().current_scene.name == "SpaceStationMenu":
        get_tree().current_scene.updateTurn()
    if player.id == id:
        player.takeTurn(false) # todo add attacking


func attack(_player):
    pass


func getPlayerByName(name):
    var names = []
    for i in players:
        names.append(i.name)
    return players[names.find(name)]


func startServer():
    # Initializing as a server, listening on the given port, with a given maximum number of peers:
    server = NetworkedMultiplayerENet.new()
    server.create_server(port, MAX_PLAYERS)
    get_tree().network_peer = Game.server
    # $Code.text = SERVER_IP
    # $Status.text = "Hosting"
    mode = SERVER
    status = "Hosting"
    allPlayerData[1] = player.getNetworkingData()


func startClient(ip=myIP):
    # assert(code)
    # assert(code.length())
    # Initializing as a client, connecting to a given IP and port:
    player.client = NetworkedMultiplayerENet.new()
    # Game.player.client.create_client(code, Game.port)
    player.client.create_client(ip, port)
    get_tree().network_peer = player.client
    mode = CLIENT
    status = "ignored"
    clientCode = ip
    allPlayerData[get_tree().get_network_unique_id()] = player.getNetworkingData()
    # $Code.text = code
