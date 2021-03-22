extends Button

export var scene: String
signal scene_recieved(scene)

func _ready():
    connect("pressed", self, "switch_scene")


func switch_scene():
    emit_signal("scene_recived", yield(Cope.gotoScene(scene), "scene_ready"))
