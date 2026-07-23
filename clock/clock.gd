extends Node2D
class_name Clock

@onready var clock := %Clock

static var instance: Clock = null

var count: int = 0

func _ready() -> void:
	instance = self
	
func update(cards: int) -> void:
	count = cards
	clock.text = str(cards)
