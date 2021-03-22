extends TextureRect

export var attackEnergyCost = 5
export var attackCreditsCost = 10

onready var attackFleet = $FleetContainer/AttackContainer/AttackFleet
onready var selectAllAttack = $FleetContainer/AttackContainer/SelectContainer/SelectAllAttack
onready var selectNoneAttack = $FleetContainer/AttackContainer/SelectContainer/SelectNoneAttack
onready var attackButton = $ButtonContainer/AttackButton

onready var defenseFleet = $FleetContainer/DefenseContainer/DefenseFleet
onready var selectAllDefense = $FleetContainer/DefenseContainer/SelectContainer/SelectAllDefend
onready var selectNoneDefense = $FleetContainer/DefenseContainer/SelectContainer/SelectNoneDefense
onready var defenseButton = $ButtonContainer/DefendButton

onready var statusNode = $ButtonContainer/Status

var prevSelectedIndex = []


enum{ATTACK, DEFENSE}
# var mode = ATTACK

func _ready():
    for ship in Game.player.shipDeck:
        if ship.attack > 0:
            appendShip(attackFleet, ship)

    for ship in Game.player.shipDeck:
        if ship.defense > 0:
            appendShip(defenseFleet, ship)



func setAsAttack(isAttack):
    if isAttack:
        selectAllDefense.disabled = true
        defenseButton.disabled = true
        selectNoneDefense.disabled = true
        for i in defenseFleet.get_item_count():
            defenseFleet.set_item_disabled(i, true)

        statusNode.text = "Preparing to attack"
    else:
        selectAllAttack.disabled = true
        attackButton.disabled = true
        selectNoneAttack.disabled = true
        for i in attackFleet.get_item_count():
            attackFleet.set_item_disabled(i, true)
        statusNode.text = "Under attack"


func appendShip(itemList, ship, useGivenTooltip=true):
    var index = itemList.get_item_count()
    itemList.add_item(ship.name, ship.icon, true)
    itemList.set_item_tooltip_enabled(index, true)
    itemList.set_item_tooltip(index, ship.tooltip if useGivenTooltip else ship.getDefaultTooltip())
    itemList.set_item_disabled(index, ship.used)


func _on_SelectAllAttack_pressed():
    for i in attackFleet.get_item_count():
        attackFleet.select(i, false)


func _on_SelectAllDefend_pressed():
    for i in defenseFleet.get_item_count():
        defenseFleet.select(i, false)


func _on_DefendButton_pressed():
    pass # Replace with function body.


func _on_SelectNoneAttack_pressed():
    attackFleet.unselect_all()


func _on_SelectNoneDefense_pressed():
    defenseFleet.unselect_all()


# func _on_DefenseFleet_item_activated(index):
#     attackFleet.select(prevSelectedIndex, false)
#     prevSelectedIndex = index


# func _on_AttackFleet_item_activated(index):
#     defenseFleet.select(prevSelectedIndex, false)
#     prevSelectedIndex = index


func _on_AttackButton_pressed():
    if Game.player.energy >= attackEnergyCost and Game.player.credts >= attackCreditsCost:
        $ButtonContainer/AttackButton/ConfirmAttack.text = "Are you sure you want to attack? It will cost %d energy and %d credits." % [attackEnergyCost, attackCreditsCost]
        $ButtonContainer/AttackButton/ConfirmAttack.popup_centered()
    else:
        Cope.toast($Toast, "You need at least %d energy and %d credits to launch an attack on another player" % [attackEnergyCost, attackCreditsCost])


func subtractFleetCost():
    Game.player.energy -= attackEnergyCost
    Game.player.credits -= attackCreditsCost


func GoBack():
    Cope.gotoSavedScene("SSMenu", true)
