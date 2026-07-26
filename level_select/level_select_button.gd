@tool
extends Button
class_name LevelSelectButton

@export var number: int = 0

var newly_unlocked: bool = false

func tile() -> Vector2i:
	return Vector2i(position / 256)
	
func reveal() -> void:
	%UnlockShimmer.play()
	%AnimationPlayer.play(&"reveal")
	await %AnimationPlayer.animation_finished

const NOT_WON_COLOR: Color = Color("ababab79")
const WON_LINE: Color = Color("43a000")
const WON_FILL: Color = Color("3b5d25")

func _ready() -> void:
	%Label.text = str(number + 1)
	text = ""
	if Engine.is_editor_hint(): return
	
	pressed.connect(func():
		%Selected.play_floating()
		get_parent().disable_all_buttons()
		Global.load_level(number)
	)
	
	print("me: ", number, " completed: ", Global.save_data.level_completed(number))
	if Global.save_data.level_completed(number):
		%Piece.self_modulate = WON_FILL
		%Piece.set_instance_shader_parameter(&"line_colour", WON_LINE)
	else:
		%Piece.self_modulate = Color.TRANSPARENT
		%Piece.set_instance_shader_parameter(&"line_colour", NOT_WON_COLOR)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		%Label.text = str(number + 1)
		text = ""
