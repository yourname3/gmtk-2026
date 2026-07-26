@tool
extends Area2D
class_name Piece

const COLOR_WHITE: Color = Color("f5ece0")
const COLOR_BLACK: Color = Color("1e130f")

var COLOR_WHITE_LINE: Color = Color("ab7f42")
var COLOR_BLACK_LINE: Color = Color("ae6c5e")

#static var color_adjust: bool = true

static var last_move_start: Vector2i = Vector2i.ZERO
static var last_move_end: Vector2i = Vector2i.ZERO
static var last_move_piece: Piece = null
static var last_move_capture: Piece = null
static var last_move_had_captured: bool = false

static var last_select_piece: Piece = null

enum Type {
	PAWN,
	ROOK,
	KNIGHT,
	BISHOP,
	QUEEN,
	KING,
}

@onready var sprite := %Sprite
# @onready var highlight := %Highlight

@export var type: Type = Type.PAWN
@export var is_black: bool = true
var has_captured: bool = false

class UndoState:
	var tile_pos: Vector2i
	var type: Type
	var alive: bool
	var is_black: bool
	var has_captured: bool
	
var undo_states: Array[UndoState] = []
	
func push_undo_state() -> void:
	var state := UndoState.new()
	state.tile_pos = tile_pos()
	state.type = type
	state.alive = alive
	state.is_black = is_black
	state.has_captured = has_captured
	
	undo_states.push_back(state)

func get_undo_pos() -> Vector2i:
	if undo_states.size() > 0:
		return undo_states.back().tile_pos
	return tile_pos() # Last ditch effort
	
func get_undo_alive() -> bool:
	if undo_states.size() > 0:
		#print(undo_states.size(), ": type: ", type, " alive: ", undo_states.back().alive)
		return undo_states.back().alive
	return false # like... if we came into being...?
	
func pop_undo_state() -> void:
	if undo_states.size() > 0:
		var state = undo_states.pop_back()
		
		var anim: StringName = &"<none>"
		if alive != state.alive:
			position = state.tile_pos * 256 # immediately return position
			anim = &"reanimate"
		elif tile_pos() != state.tile_pos:
			anim = &"hop"
		elif type != state.type or is_black != state.is_black:
			anim = &"undo"
		var animate: bool = (tile_pos() != state.tile_pos) or (type != state.type) or (alive != state.alive) or (is_black != state.is_black)
		type = state.type
		alive = state.alive
		is_black = state.is_black
		has_captured = state.has_captured
		
		if alive: show()
		else: hide()
		%AnimationPlayer.play("RESET")
		update_appearance()
		
		if anim == &"hop":
			var target: Vector2i = state.tile_pos
			var abs_dist: int = maxi(absi(target.x - tile_pos().x), absi(target.y - tile_pos().y))
			var time := 0.2 + 0.1 * abs_dist
			
			%PlacePiece.play()
			%AnimationPlayer.play(anim, -1, 0.2 / time)
			var tween = create_tween()
			tween.tween_property(self, ^"position", target * 256.0, time)
			await tween.finished
		elif anim != &"<none>":
			%AnimationPlayer.play(anim)
			await %AnimationPlayer.animation_finished
		
		Board.instance.outstanding_undos -= 1 # Tell board we are done
		position = state.tile_pos * 256

func update_appearance() -> void:
	sprite.region_rect.position.x = (256 * 5) - int(type) * 256
	sprite.self_modulate = COLOR_BLACK if is_black else COLOR_WHITE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Piece.last_move_piece = null
	Piece.last_select_piece = null
	#if color_adjust:
		#color_adjust = false
	COLOR_BLACK_LINE = COLOR_BLACK_LINE.lerp(COLOR_BLACK, 0.7)
	COLOR_WHITE_LINE = COLOR_WHITE_LINE.lerp(COLOR_WHITE, 0.7)
	
	update_appearance()
	
	if not Engine.is_editor_hint():
		# sprite.set_instance_shader_parameter(&"line_thickness", 0.0)
		sprite.material.set_shader_parameter(&"line_colour", COLOR_BLACK_LINE if is_black else COLOR_WHITE_LINE)
		
		SignalBus.preview_cleared.connect(func(): _has_preview_move = false)

var _highlight_tween: Tween = null
var _highlight_state: bool = false
var _highlight_hard: bool = false
var _highlight_special: bool = false

func _set_highlight(hl: bool, hard: bool = false) -> void:
	var special = false
	if Card.cares_about_killers():
		special = has_captured
	
	if hl == _highlight_state and hard == _highlight_hard and special == _highlight_special: return
	
	if _highlight_tween:
		_highlight_tween.kill()
		_highlight_tween = null
		
	_highlight_tween = create_tween()
	#if hl != _highlight_state:
		#_highlight_tween.tween_property(sprite, ^"instance_shader_parameters/line_thickness",
			#0.008 if hl else 0.0, 0.1).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	if true: #hard != _highlight_hard or special != _highlight_special:
		var color: Color = COLOR_BLACK_LINE if is_black else COLOR_WHITE_LINE
		var color2 = color
		if hl:
			color2 = Card.HIGHLIGHT_HARD if hard else Card.HIGHLIGHT_SOFT
			if special:
				color2 = Card.HIGHLIGHT_SPECIAL_HARD if hard else Card.HIGHLIGHT_SPECIAL_SOFT
		color = color2.lerp(color, 0.2)
		_highlight_tween.parallel().tween_property(sprite.material, ^"shader_parameter/line_colour",
			color, 0.1).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		
	_highlight_state = hl
	_highlight_hard = hard
	_highlight_special = special

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		update_appearance()
		return
		
	if BoardHighlighter.select_state == BoardHighlighter.SelectState.PIECE or \
		BoardHighlighter.select_state == BoardHighlighter.SelectState.PIECE_ONLY:
		_set_highlight(is_selectable())
	elif BoardHighlighter.select_state == BoardHighlighter.SelectState.LOCATION:
		_set_highlight(is_selectable() and not BoardHighlighter.is_tile_highlighted(tile_pos()), _is_move_selector)
	else:
		_set_highlight(false)
		
	# TODO: Not this.
	#if BoardHighlighter.select_state == BoardHighlighter.SelectState.NONE:
		#BoardHighlighter.select_state = BoardHighlighter.SelectState.PIECE

func _rook_moves(out: MoveCalculator) -> void:
	var b := Board.instance # Should be non-null cause we should only call this from calculate_moves
	var pos := tile_pos()
	b.get_move_beam(pos, Vector2i(-1, 0), out)
	b.get_move_beam(pos, Vector2i( 1, 0), out)
	b.get_move_beam(pos, Vector2i(0, -1), out)
	b.get_move_beam(pos, Vector2i(0,  1), out)
	
func _bishop_moves(out: MoveCalculator) -> void:
	var b := Board.instance # Should be non-null cause we should only call this from calculate_moves
	var pos := tile_pos()
	b.get_move_beam(pos, Vector2i(-1, -1), out)
	b.get_move_beam(pos, Vector2i(-1,  1), out)
	b.get_move_beam(pos, Vector2i( 1, -1), out)
	b.get_move_beam(pos, Vector2i( 1,  1), out)

func calculate_moves(out: MoveCalculator) -> void:
	var b := Board.instance
	var pos := tile_pos()
	if not b: return
	match type:
		Type.PAWN: # Black pawns move up, white pawns move down
			var up: int = -1 if is_black else 1
			b.add_if_not_captureable(pos + Vector2i(0, up), out)
			b.add_if_captureable(pos + Vector2i(-1, up), out)
			b.add_if_captureable(pos + Vector2i( 1, up), out)
		Type.ROOK:
			_rook_moves(out)
		Type.KNIGHT:
			b.add_if_on_board(pos + Vector2i(-1, -2), out)
			b.add_if_on_board(pos + Vector2i( 1, -2), out)
			b.add_if_on_board(pos + Vector2i(-1,  2), out)
			b.add_if_on_board(pos + Vector2i( 1,  2), out)
			b.add_if_on_board(pos + Vector2i(-2, -1), out)
			b.add_if_on_board(pos + Vector2i( 2, -1), out)
			b.add_if_on_board(pos + Vector2i(-2,  1), out)
			b.add_if_on_board(pos + Vector2i( 2,  1), out)
		Type.BISHOP:
			_bishop_moves(out)
		Type.QUEEN:
			_rook_moves(out)
			_bishop_moves(out)
		Type.KING:
			b.add_if_on_board(pos + Vector2i(-1, -1), out)
			b.add_if_on_board(pos + Vector2i( 0, -1), out)
			b.add_if_on_board(pos + Vector2i( 1, -1), out)
			b.add_if_on_board(pos + Vector2i(-1,  1), out)
			b.add_if_on_board(pos + Vector2i( 0,  1), out)
			b.add_if_on_board(pos + Vector2i( 1,  1), out)
			b.add_if_on_board(pos + Vector2i(-1,  0), out)
			b.add_if_on_board(pos + Vector2i( 1,  0), out)

var _is_move_selector: bool = false

# Performs the UI for moving the piece.
func move_this(location_only: bool = false) -> void:
	if not Card.card_playing:
		%Select.play()
	_is_move_selector = true
	last_select_piece = self
	var target = await BoardHighlighter.select_move(self, location_only)
	_is_move_selector = false
	if target != BoardHighlighter.MOVE_NULL:
		BoardHighlighter.select_state = BoardHighlighter.SelectState.NONE
		await Board.move(self, target)
		
func select_this() -> void:
	SignalBus.piece_selected.emit(self)
	BoardHighlighter.select_state = BoardHighlighter.SelectState.NONE
	
func transform_into(type: Type) -> void:
	var anim := &"transform"
	if type == self.type:
		anim = &"invalid"
	self.type = type
	%Transform.play()
	%AnimationPlayer.play(anim)
	await %AnimationPlayer.animation_finished
	
# Actually moves a piece.
func move(target: Vector2i, capture: Piece) -> void:
	last_move_piece = self
	last_move_start = tile_pos()
	last_move_end = target
	last_move_capture = capture
	last_move_had_captured = has_captured # Whether we has_captured before the move.
	var tween = create_tween()
	
	z_index = 4
	
	var anim := &"hop"
	var abs_dist: int = maxi(absi(target.x - tile_pos().x), absi(target.y - tile_pos().y))
	if abs_dist > 1 and type != Type.KNIGHT:
		if target.x > tile_pos().x:
			anim = &"slide_right"
		elif target.x < tile_pos().x:
			anim = &"slide_left"
	if abs_dist == 0:
		anim = &"invalid"
		%Error.play()
	else:
		%PlacePiece.play()

	var time := 0.2 + 0.1 * abs_dist
	
	%AnimationPlayer.stop()
	tween.tween_property(self, ^"position", target * 256.0, time).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	%AnimationPlayer.play(anim, -1, 0.2 / time)
	await tween.finished
	
	z_index = 0
	
	position = target * 256 # lock position down
	if capture != null:
		has_captured = true
	SignalBus.piece_moved.emit()
	
func tile_pos() -> Vector2i:
	return Vector2i(position / 256)
	
func will_be_captured() -> void:
	alive = false
	z_index = -1
var alive: bool = true
func kill() -> void:
	%Captured.play()
	%AnimationPlayer.play(&"captured")
	await %AnimationPlayer.animation_finished
	hide()
	#queue_free()
	
func is_selectable_side() -> bool:
	match BoardHighlighter.instance.select_filter:
		CardData.PieceFilter.SAME_SIDE:
			return is_black
		CardData.PieceFilter.ANY:
			return true
	return false
func is_major() -> bool:
	return (type == Type.ROOK) or (type == Type.QUEEN)
func is_selectable_rank() -> bool:
	match BoardHighlighter.instance.select_rank_filter:
		CardData.RankFilter.MINOR:
			return (type == Type.BISHOP) or (type == Type.KNIGHT)
		CardData.RankFilter.MAJOR:
			return is_major()
		CardData.RankFilter.NONE:
			return true
	return false
func is_selectable() -> bool:
	return is_selectable_side() and is_selectable_rank()
	
var _has_preview_move := false
func _mouse_enter() -> void:
	if Card.selected_card != null and is_selectable():
		var data := Card.selected_card.data
		match data.ability:
			CardData.SpecialAbility.ADVANCE_THEN_MOVE:
				BoardHighlighter.instance.preview_post_move(self, Board.instance._clamp_move(tile_pos(), tile_pos() + Vector2i(0, -1), Board.Continuous.HOP))
				_has_preview_move = true
			CardData.SpecialAbility.ADVANCE_X_HOP:
				BoardHighlighter.instance.preview_move(Board.instance._clamp_move(tile_pos(), tile_pos() + Vector2i(0, -Clock.instance.count), Board.Continuous.HOP))
				_has_preview_move = true
func _mouse_exit() -> void:
	if _has_preview_move:
		BoardHighlighter.instance.clear_preview()

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if Engine.is_editor_hint(): return
	
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.is_pressed():
			if is_selectable():
				if BoardHighlighter.select_state == BoardHighlighter.SelectState.PIECE:
					move_this()
				elif BoardHighlighter.select_state == BoardHighlighter.SelectState.PIECE_ONLY:
					select_this()
				elif BoardHighlighter.select_state == BoardHighlighter.SelectState.LOCATION:
					var is_selector = _is_move_selector
					# If we are not ourselves highlighted, we are allowed to steal the selection state.
					if not BoardHighlighter.is_tile_highlighted(tile_pos()):
						# First, remove the existing highlights...
						SignalBus.move_selected.emit(null)
						# Clear saved piece so we don't try to select it.
						Piece.last_select_piece = null
						# Then invoke ourselves, unless we were already selected (in that case deselect)
						if not is_selector: move_this()
						
	
