class_name Player
extends Object


var shipDeck = []
var drawPile = []
var discardPile = []
var icon: Texture = null
# var underAttack = false


var name = ''
var energy = 1
var manufactories = 1
var credits = 0
var attack = 1
var defense = 2

var client = null
var id: int
var ready = false
var status = "Not Connecting"

signal reshuffle
signal allCardsInUse


func drawShip(autoShuffle=true):
    print(drawPile)
    if drawPile.size() < 1:
        if autoShuffle:
            shuffleDiscardPile()
            #* If we've shuffled and there's still no cards, that means we're out of cards.
            if drawPile.size() < 1:
                emit_signal("allCardsInUse")
                print('Uh oh, we\'re out of cards!')
                return Game.nullShip
        else:
            return Game.nullShip

    return drawPile.pop_back()


func shuffleDiscardPile():
    emit_signal("reshuffle")
    assert(drawPile.size() + discardPile.size() == shipDeck.size())
    discardPile.shuffle()
    # for i in discardPile:
        # var s = Ship.new(i.serialize())
        # s.used = false
        # print('shuffled: ', s)
        # drawPile.append(s)
    drawPile += discardPile.duplicate()
    print('discardPile: ', discardPile)
    print('drawPile: ', drawPile)
    discardPile = []


puppet func takeTurn(underAttack):
    if underAttack:
        yield(Cope.gotoScene("CommandFeuge"), "scene_ready").setAsAttack(true)
    else:
        Cope.gotoScene("SpaceStationMenu")


master func endTurn():
    energy = 1
    manufactories = 1
    credits = 0
    attack = 1
    defense = 2
    # Game.rpc_id(1, "endTurn")


func _init(_name, startingShips):
    self.name = _name

    shipDeck = startingShips

    drawPile = [] + shipDeck


func getNetworkingData():
    return {name = name, ready = ready}


remote func init(availableShips):
    shipDeck = availableShips
    drawPile = availableShips.duplicate(true).shuffle()
