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
    Cope.debugShips(drawPile, 'drawPile')
    Cope.debugShips(discardPile, 'discardPile', true)
    if drawPile.size() < 1:
        if autoShuffle:
            if not shuffleDiscardPile():
                return Game.nullShip
        else:
            return Game.nullShip

    return drawPile.pop_back()


func shuffleDiscardPile():
    #* If we don't have enough cards in the discard pile, then don't bother
    if discardPile.size() <= 1:
        emit_signal("allCardsInUse")
        Cope.debug('Uh oh, we\'re out of cards!')
        return false
    else:
        emit_signal("reshuffle")
        # assert(drawPile.size() + discardPile.size() == shipDeck.size())
        discardPile.shuffle()
        for i in discardPile:
            # var s = Ship.new(i.serialize())
            i.used = false
            # Cope.debug('shuffled: ', s)
            # drawPile.append(s)
        drawPile += discardPile.duplicate(true)
        Cope.debugShips(discardPile, 'discardPile')
        Cope.debugShips(drawPile, 'drawPile')
        discardPile = []
        return true


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

    drawPile = shipDeck.duplicate(true)
    Cope.debugShips(drawPile, 'drawPile', true)


func getNetworkingData():
    return {name = name, ready = ready}


remote func init(availableShips):
    Cope.debugShips(availableShips, 'player init called, shipdeck')
    shipDeck = availableShips
    drawPile = availableShips.duplicate(true).shuffle()
    Cope.debugShips(drawPile, 'drawPile')
