# @tool
extends Area2D
class_name Card

static var highlighted_card: Card = null
static var selected_card: Card = null
static var selected_hard: bool = false

static var card_playing: bool = false

var target_position: Vector2 = position
var target_scale: Vector2 = Vector2.ONE
var target_rotation: float = 0.0

const HIGHLIGHT_SOFT: Color = Color("70b3cd")
const HIGHLIGHT_HARD: Color = Color("a9d7ea")

@onready var highlight: Sprite2D = %Highlight

@export var data: CardData = CardData.new()

enum State {
	NORMAL,
	PLAYING,
	DYING,
}

var _state: State = State.NORMAL

static func is_activated_on_piece_move() -> bool:
	if selected_card != null:
		return selected_card.data.activation == CardData.Activate.PieceMove
	return false
static func is_activated_on_piece_select() -> bool:
	if selected_card != null:
		return selected_card.data.activation == CardData.Activate.PieceSelect
	return false

#func _ready() -> void:
	#mouse_entered.connect(func(): highlighted_card = self)
	#mouse_exited.connect(func(): if is_highlighted(): highlighted_card = null)

func is_highlighted() -> bool:
	return highlighted_card == self
	
func is_selected() -> bool:
	return selected_card == self

func _update_text() -> void:
	%Title.text = data.name
	%Description.text = data.description

func _update_pos() -> void:
	if _state == State.DYING: return # no updates here
	
	var tpos := target_position
	var tscale := target_scale
	var trot := target_rotation
	
	if not Engine.is_editor_hint():
		z_index = 0
		if is_highlighted() or is_selected():
			tpos.y = -30
			tscale = Vector2(1.15, 1.15)
			trot = 0
			z_index = 2
			
		if _state == State.PLAYING:
			tpos = get_parent().to_local(CardAnchor.instance.global_position)
			tscale = 1.2 * Vector2.ONE
			trot = -PI / 38
		
	
	position += (tpos - position) * 0.3
	scale += (tscale - scale) * 0.3
	rotation = lerp_angle(rotation, trot, 0.3)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		_update_pos()
		_update_text()
		return
	
	_update_pos()
	if is_selected() and _state != State.DYING:
		highlight.visible = true
		highlight.modulate = HIGHLIGHT_HARD if selected_hard else HIGHLIGHT_SOFT
	else:
		highlight.visible = false
		
func play(selected_piece: Piece = null) -> void:
	card_playing = true
	_state = State.PLAYING
	SignalBus.card_played.emit(self)
	
	# Remove selection
	selected_card = null
	highlighted_card = null
	selected_hard = false
	
	# Resolve each other step in the card...
	await data.await_activation_full_resolve()
	await data.perform_additional_steps(selected_piece)
	
	_state = State.DYING
	card_playing = false
	SignalBus.card_finished_playing.emit()
	
	die_anim()
	
func die_anim() -> void:
	# To die... animate out?
	var tween = create_tween()
	tween.tween_property(self, ^"position", position - Vector2(200, 900), 2.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(self, ^"modulate", Color(1.0, 1.0, 1.0, 0.0), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(self, ^"scale", Vector2.ONE * 1.3, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	await tween.finished
	queue_free()
	
func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	_update_text()
	
	SignalBus.piece_started_moving.connect(func():
		if is_selected() and is_activated_on_piece_move():
			play()
	)
	
	SignalBus.piece_selected.connect(func(piece: Piece):
		if is_selected() and is_activated_on_piece_select():
			play(piece)
	)
