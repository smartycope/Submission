extends Node

var nullShip = Ship.new("You've run out of ships", "res://nullShipIcon.png", -1, "This is the phantom null ship. Please dispose of it promptly.", -1, -1, -1, -1, -1, -1, 'This ship is here because you\'ve run out of ships', "This is a naughty ship.")

var Ai = load("res://AI.gd")

var turn = 1

var port = 6667

# players is now a list of names
var players = []
var player = null # The current player
var turnIndex = 0 # The index of the player who's turn it currently is
const startingDeckSize = 10

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


func endTurn():
    turn += 1

    # players[turnIndex].energy = 1
    player.energy = 1
    # players[turnIndex].manufactories = 1
    player.manufactories = 1
    # players[turnIndex].credits = 0
    player.credits = 0
    # players[turnIndex].attack = 1
    player.attack = 1
    # players[turnIndex].defense = 2
    player.defense = 2
    # players[turnIndex].shuffleDiscardPile()
    # player.shuffleDiscardPile()

    if mode == AI or get_tree().is_network_server():
        turnIndex = turn - 1
        turnIndex = wrapi(turnIndex, 0, players.size() - 1)
        # players[turnIndex].takeTurn(false) # This parameter must change eventually
        # rpc


func attack(player):
    pass


func getPlayerByName(name):
    var names = []
    for i in players:
        names.append(i.name)
    return players[names.find(name)]
