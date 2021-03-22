extends MeshInstance

export var rotationStep = .003
export var rotateClockwise = true

func rotateStep():
    rotate_object_local(Vector3(0, 1, 0), rotationStep) # * -1.0 if rotateClockwise else 1.0)
