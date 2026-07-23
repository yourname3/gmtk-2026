@tool
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

static func is_activated_on_piece_move() -> bool:
	if selected_card != null:
		return selected_card.data.activation == CardData.Activate.PieceMove
	return false

#func _ready() -> void:
	#mouse_entered.connect(func(): highlighted_card = self)
	#mouse_exited.connect(func(): if is_highlighted(): highlighted_card = null)

func is_highlighted() -> bool:
	return highlighted_card == self
	
func is_selected() -> bool:
	return selected_card == self

func _update_text() -> void:
	%Title.text = "title"
	%Description.text = data.description

func _update_pos() -> void:
	var tpos := target_position
	var tscale := target_scale
	var trot := target_rotation
	
	z_index = 0
	if is_highlighted() or is_selected():
		tpos.y = -30
		tscale = Vector2(1.15, 1.15)
		trot = 0
		z_index = 2
	
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
	if is_selected():
		highlight.visible = true
		highlight.modulate = HIGHLIGHT_HARD if selected_hard else HIGHLIGHT_SOFT
	else:
		highlight.visible = false
		
func play() -> void:
	card_playing = true
	
	# Remove selection
	selected_card = null
	highlighted_card = null
	selected_hard = false
	
	# Resolve each other step in the card...
	await data.await_activation_full_resolve()
	await data.perform_additional_steps()
	
	queue_free()
	card_playing = false
	SignalBus.card_finished_playing.emit()
	
func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	_update_text()
	
	SignalBus.piece_started_moving.connect(func():
		if is_selected() and is_activated_on_piece_move():
			play()
	)
