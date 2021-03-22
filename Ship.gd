class_name Ship
extends Object

var name: String
var tooltip: String
var icon
var description: String
var actionDescription: String

var energy: int
var manufactories: int
var dockingPorts: int
var credits: int
var defense: int
var attack: int

var used = false

var cost: int


func _init(_name, _icon=null, _cost=null, _description=null, _energy=null, _manufactories=null, _credits=null,
          _defense=null, _attack=null, _dockingPorts=null, _tooltip='', _actionDescription=''):
    if _name is Dictionary:
        deserialize(_name)
    else:
        self.name = _name
        # if _icon is String:
        # self.icon = load(_icon)
        # else:
        self.icon = _icon
        self.description = _description
        self.energy = _energy
        self.manufactories = _manufactories
        self.credits = _credits
        self.defense = _defense
        self.attack = _attack
        self.dockingPorts = _dockingPorts
        self.tooltip = _tooltip
        self.actionDescription = _actionDescription
        self.cost = _cost


func deserialize(dict):
    self.name = dict["name"]
    self.icon = dict["icon"]
    self.cost = dict["cost"]
    self.description = dict["description"]
    self.energy = dict["energy"]
    self.manufactories = dict["manufactories"]
    self.credits = dict["credits"]
    self.defense = dict["defense"]
    self.attack = dict["attack"]
    self.dockingPorts = dict["dockingPorts"]
    self.tooltip = dict["tooltip"]
    self.actionDescription = dict["actionDescription"]


func serialize():
    var dict = {}
    dict["name"] = self.name
    dict["icon"] = self.icon
    dict["cost"] = self.cost
    dict["description"] = self.description
    dict["energy"] = self.energy
    dict["manufactories"] = self.manufactories
    dict["credits"] = self.credits
    dict["defense"] = self.defense
    dict["attack"] = self.attack
    dict["dockingPorts"] = self.dockingPorts
    dict["tooltip"] = self.tooltip
    dict["actionDescription"] = self.actionDescription
    return dict


func getFullDescription():
    return description + "\n\nEnergy: %d\nManuFactories: %d\nCredits: %d\nDefense: %d\nAttack: %d\nDocking Ports: %d\nCosts: %d\n\n%s" % [energy, manufactories, credits, defense, attack, dockingPorts, cost, actionDescription]


func getDefaultTooltip():
    return "Energy: %d\nManuFactories: %d\nCredits: %d\nDocking Ports: %d" % [energy, manufactories, credits, dockingPorts]


# How to make a new ship in ships.json
#   {
#       "name": "",
#       "icon": "res://shipIcons/",
#       "cost": ,
#       "description": "",
#       "energy": 0,
#       "manufactories": 0,
#       "credits": 0,
#       "defense": 0,
#       "attack": 0,
#       "dockingPorts": 0,
#       "tooltip": "",
#       "actionDescription": ""
#   },
