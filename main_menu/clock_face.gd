extends Sprite2D
class_name ClockFace

var seconds: int = 15
var minutes: int = 48

@onready var minute_hand = %Minute
@onready var second_hand = %Second

@export var always_update: bool = false

func update_face(init: bool = false) -> void:
	var next_sec := TAU * seconds / 60.0
	var next_min := TAU * minutes / 60.0
	
	if not init:
		var tween = create_tween()
		tween.tween_property(minute_hand, ^"rotation", next_min, 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
		tween.parallel().tween_property(second_hand, ^"rotation", next_sec, 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
		await tween.finished
	
	second_hand.rotation = next_sec
	minute_hand.rotation = next_min

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_face(true)
	while true:
		await get_tree().create_timer(1.0, always_update).timeout
		seconds += 1
		if seconds >= 60:
			seconds -= 60
			minutes = (minutes + 1) % 60
		update_face()
