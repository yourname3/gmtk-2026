extends Resource
class_name CardData

enum Activate {
	PieceMove,
	PieceSelect,
}

enum SpecialAbility {
	None,
	RepeatMove,
	TransformRook,
}

@export var activation: Activate = Activate.PieceMove
@export var ability: SpecialAbility = SpecialAbility.None
@export var description: String = "Card description"

func await_activation_full_resolve() -> void:
	if activation == Activate.PieceMove:
		await SignalBus.piece_moved

func perform_additional_steps(selected_piece: Piece) -> void:
	match ability:
		SpecialAbility.RepeatMove:
			var piece = Piece.last_move_piece
			var pos := Piece.last_move_end
			var diff := Piece.last_move_end - Piece.last_move_start
			for i in range(0, 1):
				pos += diff
				Board.move(piece, pos)
				await SignalBus.piece_moved
		SpecialAbility.TransformRook:
			selected_piece.transform_into(Piece.Type.ROOK)
