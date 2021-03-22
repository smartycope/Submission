class_name Spacer
extends Control

export(int) var hSpacing = 10
export(int) var vSpacing = 10

func _ready():
    rect_min_size = Vector2(hSpacing, vSpacing)
