extends Sprite2D
class_name ChessboardParticle

var height: float = 256
var decay_time: float = 0.5
var extra_time: float = 0.5 # time before scaling

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var motion_rate := height # move across ourselves in 1 second
	var tween := create_tween()
	tween.tween_property(self, ^"position", position + Vector2(motion_rate * (decay_time + extra_time), 0), decay_time + extra_time)
	
	tween = create_tween() # separate tween for scale...
	tween.tween_interval(extra_time)
	tween.tween_property(self, ^"scale", Vector2.ZERO, decay_time)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
