extends TextureRect

onready var shipList = $ShipList
onready var description = $DescriptionContainer/Description
onready var title = $DescriptionContainer/Title
onready var shipIcon = $DescriptionContainer/ShipIcon
onready var statusNode = $Status

onready var creditsNode = $GridContainer/Credits
onready var manuNode = $GridContainer/ManuFactories

var selectedIndex

func _ready():
    creditsNode.text = str(Game.player.credits)
    manuNode.text = str(Game.player.manufactories)
    for i in Game.ships:
        shipList.add_item(i.name, i.icon)
        shipList.set_item_tooltip(-1, i.tooltip)


func showDescription(index):
    selectedIndex = index
    title.text = Game.ships[index].name
    description.text = '\n' + Game.ships[index].getFullDescription()
    shipIcon.texture = Game.ships[index].icon


func endTurn():
    # Cope.gotoScene("SpaceStationMenu")
    var s = yield(Cope.gotoSavedScene("SSMenu"), "scene_ready")
    s.updateLabels()
    s.updateResources()



# func goBack():
#     # print('No.')
#     Cope.gotoSavedScene("SSMenu")


func purchaseShip():
    if selectedIndex != null and\
       Game.player.credits >= Game.ships[selectedIndex].cost and \
       Game.player.manufactories >= 1:
        Game.player.shipDeck.append(Ship.new(Game.ships[selectedIndex].serialize()))
        Game.player.credits -= Game.ships[selectedIndex].cost
        Game.player.manufactories -= 1

        creditsNode.text = str(Game.player.credits)
        manuNode.text = str(Game.player.manufactories)

        Cope.toast($Status, 'Success!')
    elif Game.player.credits < Game.ships[selectedIndex].cost:
        Cope.toast($Status, "Not Enough Money")
    elif Game.player.manufactories < 1:
        Cope.toast($Status, "Not ManuFactories")
    else:
        Cope.toast($Status, "You Must Select a Ship")
