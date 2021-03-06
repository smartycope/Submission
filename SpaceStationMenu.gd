extends Control

onready var shipList = $Ships/ShipContainer/ShipsGrid/ShipList
onready var dockingPortList = $Ships/ShipContainer/ShipsGrid/DockingPortList

onready var energyNode = $Resources/ResourcesAndInfo/ResourcesGrid/Energy
onready var manufactoriesNode = $Resources/ResourcesAndInfo/ResourcesGrid/ManuFactories
onready var creditsNode = $Resources/ResourcesAndInfo/ResourcesGrid/Credits
onready var attackNode = $Resources/ResourcesAndInfo/ResourcesGrid/Attack
onready var defenseNode = $Resources/ResourcesAndInfo/ResourcesGrid/Defense
onready var totalShipsNode = $Resources/ResourcesAndInfo/InfoGrid/TotalShips
onready var turnNode = $Resources/ResourcesAndInfo/InfoGrid/Turn

var waitingPopup = load("res://WaitingPopup.tscn").instance()
onready var playerLabel  = waitingPopup.get_node("PlayerLabel")

export var notMyTurnText = "It's %s's turn."

export var emptyPortText = "This is port is empty."
export var emptyPortTooltip = ''

var dockingPorts
var dockedShips

var outOfShips = false


func disableAll():
    outOfShips = true
    Cope.toast($Toast, "You've used all of your ships this turn!")
    for i in shipList.get_item_count():
        shipList.set_item_disabled(i, true)


func _ready():
    # set_process_input(true)

    dockingPorts = ["Docking Port 1", "Docking Port 2", "Docking Port 3", "Docking Port 4", "Docking Port 5"]
    dockedShips  = []

    Game.player.connect("allCardsInUse", self, "disableAll")

    #* Update the total cards and the turn counter
    # turnNode.text = str(Game.turn)
    # totalShipsNode.text = str(Game.player.shipDeck.size())
    updateLabels()

    for i in dockingPorts.duplicate():
        dockedShips.append(newShip(false))

    for ship in dockedShips.duplicate():
        newPort(ship)

    updateShipList()
    updateResources()

    # print("SSMenu._ready() is almost finished running")
    # updateTurn()
    Cope.debug("SSMenu._ready() is finished running")


# func _input(event):
    # if(event is InputEventMouseButton && event.button_index == BUTTON_LEFT):
    #     Cope.debug("Clicked!")
    #     print_tree_pretty()


func updateResources():
    energyNode.text = str(Game.player.energy)
    manufactoriesNode.text = str(Game.player.manufactories)
    creditsNode.text = str(Game.player.credits)
    attackNode.text = str(Game.player.attack)
    defenseNode.text = str(Game.player.defense)


func updateShipList():
    assert(dockingPorts.size() == dockedShips.size())

    shipList.clear()

    #* Get the longest port name
    # var maxLen = 0
    # for i in dockingPorts:
    #     if i.length() > maxLen:
    #         maxLen = i.length()

    for i in dockingPorts.size():
        #* var portText = ("%-" + str(maxLen) + "s    ") % (i + ':')
        var portText = dockingPorts[i] + ':  '

        if dockedShips[i] != null:
            shipList.add_item(portText + dockedShips[i].name, dockedShips[i].icon, true)
            # shipList.set_item_tooltip(-1, dockedShips[i].tooltip)
            # if dockedShips[i].used:
                # shipList.set_item_disabled(-1, true)
        else:
            shipList.add_item(portText + emptyPortText, null, true)
            # shipList.set_item_tooltip(-1, emptyPortTooltip)
            # shipList.set_item_disabled(-1, true)

    for i in dockedShips.size():
        shipList.set_item_tooltip(i, emptyPortTooltip if dockedShips[i] == null else dockedShips[i].getDefaultTooltip())
        if dockedShips[i] and dockedShips[i].used:
            shipList.set_item_disabled(i, true)


func newShip(addPorts=true):
    if not outOfShips:
        var ship = Game.player.drawShip()

        if addPorts:
            newPort(ship)

        return ship
    else:
        return Game.nullShip


func newPort(ship):
    for i in ship.dockingPorts:
        dockingPorts.append(ship.name)
        dockedShips.append(null)


func shipUsed(index):
    # Cope.debug("The ship at index %d was just used" % index)
    if dockedShips[index] != null and Game.player.energy > 0 and not dockedShips[index].used:
        var ship = dockedShips[index]

        Game.player.discardPile.append(ship)

        Cope.debug("setting %s to be used!" % ship.name)
        ship.used = true
        Game.player.energy += ship.energy - 1
        Game.player.manufactories += ship.manufactories
        Game.player.credits += ship.credits


        updateResources()

        var dockedIndex = 0
        for i in dockingPorts:
            if i == ship.name and dockedShips[dockedIndex] == null:
                dockedShips[dockedIndex] = newShip()
                break
            dockedIndex += 1

        updateShipList()

    else:
        if Game.player.energy < 1:
            Cope.toast($Toast, "Not enough energy")
        elif dockedShips[index] == null:
            Cope.toast($Toast, "You must use another ship to dock to this port", 3)
        elif dockedShips[index].used:
            Cope.toast($Toast, "That ship has already been used")


func endTurn():
    #* Update the total cards and the turn counter
    # turnNode.text = str(Deck.turn)
    # totalShipsNode.text = str(Deck.shipDeck.size())



    for i in dockedShips:
        # if i and not i.used:
        Game.player.discardPile.append(i)

    Game.endTurn()

    # rpc_id(1, "turn_finished")

    # dockingPorts = ["Docking Port 1", "Docking Port 2", "Docking Port 3", "Docking Port 4", "Docking Port 5"]
    # dockedShips  = []

    # for i in dockingPorts.duplicate():
    #     dockedShips.append(newShip(false))

    # for ship in dockedShips.duplicate():
    #     newPort(ship)

    # updateShipList()
    # updateResources()


func updateTurn():
    Cope.debug("called updateTurn(). $WaitingPopup is " + str(waitingPopup) + ", Game.currentTurnName is %s, and my player's name is %s." % [Game.currentTurnName, Game.player.name])
    if Game.currentTurnName != Game.player.name:
        waiting()
    else:
        notWaiting()


func waiting():
    Cope.debug('waiting called')
    # waitingPopup = load("res://WaitingPopup.tscn").instance()
    # get_node(".").add_child(waitingPopup)
    # playerLabel = waitingPopup.get_node("PlayerLabel")
    # waitingPopup.popup()
    # playerLabel.text = "It's %s's turn" % Game.currentTurnName
    # Cope.popup('Waiting for other players', "It's %s's turn" % Game.currentTurnName)
    get_tree().get_root().get_node("SpaceStationMenu").add_child(waitingPopup, true)
    $WaitingPopup.popup_centered()
    $WaitingPopup/PlayerLabel.text =  notMyTurnText % Game.currentTurnName


func notWaiting():
    # print_tree_pretty()
    if is_instance_valid($WaitingPopup):
        $WaitingPopup.queue_free()
    # print_tree_pretty()

    Cope.gotoScene("SpaceStationMenu")
    # shipList.grab_focus()
    # waitingPopup.free()
    # waitingPopup = null
    # playerLabel  = null


# remote func turn_finished():
#     assert(get_tree().get_network_unique_id() == 1)

#     rpc("takeTurn", Game.players[Game.turnIndex], false)


remote func takeTurn(name, underAttack):
    pass
    # if name == Game.player.name:
    #     Game.player.takeTurn(underAttack)


#* Depricated
func updateDockingPortList():
    return
    for i in dockingPortList.get_children():
        dockingPortList.remove_child(i)
        i.queue_free()

    for i in dockingPorts:
        dockingPortList.add_item(i + dockingPorts[i].name, true)
        # var label = Label.new()
        # if i != null
            # label.text = i.name
        # else
        # label.text = i
        # label.add_font_override('', dockingPortLabelFont)
        # label.theme.set_font('spess', 'Label', dockingPortLabelFont)
        # label.set("custom_fonts/font", dockingPortLabelFont)
        # label.set("custom_fonts/settings/size", 32)
        # dockingPortList.add_child(label)


func buyShips():
    Cope.saveScene("SSMenu", self)
    Cope.gotoScene("Hanger", false)


func updateLabels():
    turnNode.text = str(Game.turn)
    totalShipsNode.text = str(Game.player.shipDeck.size())


func _on_GoToBridge_pressed():
    Cope.saveScene("SSMenu", self)
    Cope.gotoScene("CommandFeuge", false)
