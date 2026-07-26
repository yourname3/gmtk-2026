extends Area2D
class_name BoardHighlight

var die_pitch: float = 1.0
var die_time: float = 0.0

var move_rel: Vector2i = Vector2.ZERO
var red: bool = false

func die(fun: bool) -> void:
	if fun:
		%Tink.pitch_scale = die_pitch
		%Tink.play_floating(die_time)
	queue_free()

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.is_pressed():
			SignalBus.move_selected.emit(self)
			
func _ready() -> void:
	SignalBus.preview_cleared.connect(func(): _has_preview_move = false)
			
func tile_pos() -> Vector2i:
	return Vector2i(position / 256)
			
var _has_preview_move := false
func _mouse_enter() -> void:
	if red: return
	
	if Card.selected_card != null:
		var data := Card.selected_card.data
		match data.ability:
			CardData.SpecialAbility.RepeatMove:
				BoardHighlighter.instance.preview_moves_red([Board.instance._clamp_move(tile_pos(), tile_pos() + move_rel, Board.Continuous.AUTO)])
				_has_preview_move = true
			CardData.SpecialAbility.REPEAT_TWO:
				var one := Board.instance._clamp_move(tile_pos(), tile_pos() + move_rel, Board.Continuous.AUTO)
				var two = Board.instance._clamp_move(one, one + move_rel, Board.Continuous.AUTO)
				BoardHighlighter.instance.preview_moves_red([
					one, two
				])
				_has_preview_move = true
				
func _mouse_exit() -> void:
	if _has_preview_move:
		BoardHighlighter.instance.clear_preview()
		
func redify() -> void:
	z_index += 1
	%Sprite.texture = preload("res://chessboard/highlight_red.png")
	
	red = true
