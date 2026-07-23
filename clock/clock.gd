extends Node2D
class_name Clock

@onready var clock := %Clock

static var instance: Clock = null

func _ready() -> void:
	instance = self
	
func update(cards: int) -> void:
	clock.text = str(cards)
