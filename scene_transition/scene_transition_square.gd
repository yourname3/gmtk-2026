extends Sprite2D
class_name SceneTransitionSquare

var delay: float = 0.0
var done: bool = false
var my_color: Color = Color.WHITE

var rot: float = 0

func _ready() -> void:
	scale = Vector2.ZERO
	#rotation_degrees = -45
	rot = rotation
	
	my_color = modulate
	#modulate = my_color.darkened(0.5)
	
	var final_pos = position
	position -= Vector2(256, 128)
	
	var tween := create_tween()
	tween.tween_interval(delay)
	tween.tween_property(self, ^"scale", 0.5 * Vector2.ONE, 0.2).set_ease(Tween.EASE_IN)#.set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(self, ^"rotation", 0, 0.2).set_ease(Tween.EASE_IN)#.set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(self, ^"position", final_pos, 0.2).set_ease(Tween.EASE_IN)
	
	#tween.parallel().tween_property(self, ^"modulate", my_color, 0.25)
	#tween.parallel().tween_interval(0.05)
	#tween.tween_property(self, ^"modulate", Color.WHITE, 0.15)
	tween.tween_callback(func(): done = true)
	tween.tween_property(self, ^"modulate", Color.WHITE, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

func second_anim() -> void:
	var tween := create_tween()
	tween.tween_interval(delay)
	tween.tween_property(self, ^"scale", Vector2.ZERO, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(self, ^"rotation", -rot, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	#tween.parallel().tween_property(self, ^"modulate", Color.WHITE, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(self, ^"position", position + Vector2(256, 128), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(queue_free)
