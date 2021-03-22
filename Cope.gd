extends Node

# var current_scene = null
var instancedScenes = {}

onready var root = get_tree().get_root()
#* The last scene is always loaded as the current scene
onready var current_scene = root.get_child(root.get_child_count() - 1)

func _ready():
    randomize()

    #* Call test code here
    # assert(null != 0)


func toast(labelNode, text, time=2.5):
    labelNode.text = text
    yield(get_tree().create_timer(time), "timeout")

    if is_instance_valid(labelNode):
        labelNode.text = ""


class SceneLoader:
    extends Object
    # signal scene_ready(scene)
    signal scene_ready

    var tree_func
    var instanced_scenes
    var current_scene

    func _init(sceneTreeFunc, currentScene, sceneName, isPath=false, freeCurrentScene=true, isSaved=false, instancedScenes={}):
        tree_func = sceneTreeFunc
        current_scene = currentScene
        instanced_scenes = instancedScenes

        if isSaved:
            assert(not isPath)
            call_deferred("_deferred_load_scene", sceneName, freeCurrentScene)
        else:
            call_deferred("_deferred_goto_scene", sceneName if isPath else "res://" + sceneName + ".tscn", freeCurrentScene)

    func _deferred_goto_scene(name, free=true):
        var oldScene = current_scene.duplicate(true)

        # Load the new scene.
        var s = ResourceLoader.load(name)

        # Instance the new scene.
        current_scene = s.instance()

        # Add it to the active scene, as child of root.
        tree_func.call_func().get_root().add_child(current_scene)

        # Optionally, to make it compatible with the SceneTree.change_scene() API.
        tree_func.call_func().set_current_scene(current_scene)

        Cope.current_scene = current_scene

        # yield(current_scene, "ready")
        emit_signal("scene_ready", current_scene)

        # It is now safe to remove the old scene
        if free:# and is_instance_valid(oldScene):
            oldScene.free()


    func _deferred_load_scene(id, free=true):
        var oldScene = current_scene.duplicate(true)

        # Instance the new scene.
        current_scene = instanced_scenes[id]

        # Add it to the active scene, as child of root.
        tree_func.call_func().get_root().add_child(current_scene)

        # Optionally, to make it compatible with the SceneTree.change_scene() API.
        tree_func.call_func().set_current_scene(current_scene)

        Cope.current_scene = current_scene

        # yield(current_scene, "ready")
        emit_signal("scene_ready", current_scene)

        # It is now safe to remove the old scene
        if free:# and is_instance_valid(oldScene):
            oldScene.free()


func saveScene(currentSceneName, currentSceneInstance):
    instancedScenes[currentSceneName] = currentSceneInstance

func gotoSavedScene(name, freeScene=true, isPath=false):
    return SceneLoader.new(funcref(self, "get_tree"), current_scene, name, isPath, freeScene, true, instancedScenes)

func gotoScene(name, freeScene=true, isPath=false):
    return SceneLoader.new(funcref(self, "get_tree"), current_scene, name, isPath, freeScene)




static func getJSON(filename):
    var file = File.new()
    file.open("res://" + filename, File.READ)
    var json = JSON.parse(file.get_as_text())
    file.close()

    assert(json.error == OK)

    return json.result


static func setJSON(filename):
    var file = File.new()
    file.open("res://" + filename, File.WRITE)
    # var json = JSON.parse(file.get_as_text())
    # file.
    print("You haven't actually written this function yet, bozo.")
    assert(false)
    file.close()

    #assert(json.error == OK)
