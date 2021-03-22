class_name Player
extends Object


var shipDeck = []
var drawPile = []
var discardPile = []
var icon: Texture = null
var id: int

# var underAttack = false


var name = ''
var energy = 1
var manufactories = 1
var credits = 0
var attack = 1
var defense = 2

var client = null

signal reshuffle
signal allCardsInUse


func drawShip(autoShuffle=true):
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
    discardPile.shuffle()
    for i in discardPile:
        drawPile.append(Ship.new(i.serialize()))
        drawPile[-1].used = false
    # drawPile += discardPile
    discardPile = []


func takeTurn(underAttack):
    if underAttack:
        yield(Cope.gotoScene("CommandFeuge"), "scene_ready").setAsAttack(true)
    else:
        Cope.gotoScene("SpaceStationMenu")


func _init(name, startingShips):
    self.name = name

    shipDeck = startingShips

    drawPile = [] + shipDeck

remote func init(availableShips):
    shipDeck = availableShips
    drawPile = availableShips.duplicate(true).shuffle()
