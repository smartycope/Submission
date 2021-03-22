extends Node

var nullShip = Ship.new("You've run out of ships", "res://nullShipIcon.png", -1, "This is the phantom null ship. Please dispose of it promptly.", -1, -1, -1, -1, -1, -1, 'This ship is here because you\'ve run out of ships', "This is a naughty ship.")

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
const startingDeckSize = 10
var currentTurnName = 'root'

const MAX_PLAYERS = 20

var clientCode = myIP

var playerTurnOrder = []

var ships = []
var useableShips = []

var mode

var server = null

enum {AI, SERVER, CLIENT}

func _ready():
    nullShip.used = true

    for i in Cope.getJSON('ships.json'):
        ships.append(Ship.new(i))

    for i in ships:
        i.icon = load(i.icon)

    for i in startingDeckSize:
        useableShips.append(Ship.new(ships[int(rand_range(0, ships.size()))].serialize()))

    # for i in ships:
        # print('-', i.icon)

    # print('~', load("res://nullShipIcon.png"))

    var Player = load("res://Player.gd")

    players.append(Player.new(Cope.getJSONvalue("settings.json", "name"), useableShips))
    player = players[0]
    players.append(Ai.new(Ai.EASY))


remote func endTurn():
    turn += 1

    if get_tree().is_network_server():
        turnIndex = turn - 1
        turnIndex = wrapi(turnIndex, 0, players.size() - 1)

    rpc("itsIDsTurn", playerTurnOrder[turnIndex])


        # players[turnIndex].takeTurn(false) # This parameter must change eventually
        # rpc


remote func itsIDsTurn(id):
    currentTurnName = allPlayerData[id]['name']
    if player.id == id:
        player.takeTurn()



func attack(player):
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
    # $Code.text = code
