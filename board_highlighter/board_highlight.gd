extends Area2D
class_name BoardHighlight

var die_pitch: float = 1.0
var die_time: float = 0.0
var delay: float = 0.0

var move_rel: Vector2i = Vector2.ZERO
var is_preview_move: bool = false

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
	
	%Sprite.scale = Vector2.ZERO
	
	await get_tree().process_frame # wait until we get our delay assignment
	await get_tree().create_timer(delay, true).timeout
	%AnimationPlayer.play(&"appear")
			
func tile_pos() -> Vector2i:
	return Vector2i(position / 256)
			
var _has_preview_move := false
func _mouse_enter() -> void:
	if is_preview_move: return
	
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
		
func previewify() -> void:
	is_preview_move = true
	input_pickable = false
		
func redify() -> void:
	z_index += 1
	%Sprite.texture = preload("res://chessboard/highlight_red.png")
	
	previewify()
	
func specialify() -> void:
	%Sprite.texture = preload("res://chessboard/highlight_special.png")
