@tool
extends Node2D
class_name Piece

const COLOR_WHITE: Color = Color("f5ece0")
const COLOR_BLACK: Color = Color("1e130f")

enum Type {
	PAWN,
	ROOK,
	KNIGHT,
	BISHOP,
	QUEEN,
	KING,
}

@onready var sprite := %Sprite

@export var type: Type = Type.PAWN
@export var is_black: bool = true

func update_appearance() -> void:
	sprite.region_rect.position.x = (256 * 5) - int(type) * 256
	sprite.modulate = COLOR_BLACK if is_black else COLOR_WHITE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_appearance()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		update_appearance()
		return
