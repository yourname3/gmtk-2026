extends Node2D
class_name CardAnchor

static var instance: CardAnchor = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instance = self
