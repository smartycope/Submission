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

func popup(title, text):
    var p = AcceptDialog.new()
    p.window_title = title
    p.dialog_text = text
    p.popup_exclusive = false
    p.connect("confirmed", p, "free")
    get_tree().get_root().add_child(p)
    p.popup_centered()

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
        var oldScene = current_scene

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
        if free and is_instance_valid(oldScene):
            oldScene.free()


    func _deferred_load_scene(id, free=true):
        var oldScene = current_scene

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
        if free and is_instance_valid(oldScene):
            oldScene.free()


func saveScene(currentSceneName, currentSceneInstance):
    instancedScenes[currentSceneName] = currentSceneInstance

func gotoSavedScene(name, freeScene=true, isPath=false):
    return SceneLoader.new(funcref(self, "get_tree"), current_scene, name, isPath, freeScene, true, instancedScenes)

func gotoScene(name, freeScene=true, isPath=false):
    return SceneLoader.new(funcref(self, "get_tree"), current_scene, name, isPath, freeScene)


static func debugShips(shipList, prefix=''):
    var text = ''
    for i in shipList:
        text += i.name + ', '
    debug('[' + text + ']', prefix)


static func getJSON(filename):
    var file = File.new()
    file.open("res://" + filename, File.READ)
    # var data = file.get_var()
    # file.close()
    # return data

    var json = JSON.parse(file.get_as_text())
    file.close()
    assert(json.error == OK)
    return json.result


static func setJSON(filename, data, full=false):
    var file = File.new()
    file.open("res://" + filename, File.WRITE)
    # file.store_var(data)
    file.store_var(to_json(data), full)
    file.close()


static func setJSONvalue(filename, key, value):
    var data = getJSON(filename)
    data[key] = value
    setJSON(filename, data)


static func getJSONvalue(filename, key):
    return getJSON(filename)[key]


static func debug(text, prefix=''):
    var frame = get_stack()[1]
    print('--', frame, '--')
    print(prefix, ': ' if len(prefix) else '', "%30s:%-4d %s" % [frame.source.get_file(), frame.line, text])