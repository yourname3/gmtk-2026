extends Node2D
class_name Clock

@onready var clock := %Clock

static var instance: Clock = null

var count: int = 0

func _ready() -> void:
	instance = self

func _anim_update_clock() -> void:
	clock.text = str(count)
	
func update(cards: int) -> void:
	if count != cards:
		%ClockFuture.text = str(cards)
		%AnimationPlayer.play(&"flip")
	count = cards
	
