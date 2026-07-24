extends Resource
class_name CardData

enum Activate {
	PieceMove,
	PieceSelect,
}

enum PieceFilter {
	SAME_SIDE,
	ANY,
}

enum SpecialAbility {
	None,
	RepeatMove,
	TransformRook,
	MoveSamePieceX,
	SACRIFICE_ON_CAPTURE,
	KNIGHT_ON_CAPTURE,
	REPEAT_X,
	REPEAT_TWO,
}

@export var activation: Activate = Activate.PieceMove
@export var piece_filter: PieceFilter = PieceFilter.SAME_SIDE
@export var ability: SpecialAbility = SpecialAbility.None
@export var name: String = "Card Name"
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
		SpecialAbility.REPEAT_TWO:
			var piece = Piece.last_move_piece
			var pos := Piece.last_move_end
			var diff := Piece.last_move_end - Piece.last_move_start
			for i in range(0, 2):
				pos += diff
				Board.move(piece, pos)
				await SignalBus.piece_moved
		SpecialAbility.REPEAT_X:
			var piece = Piece.last_move_piece
			var pos := Piece.last_move_end
			var diff := Piece.last_move_end - Piece.last_move_start
			var repeats := Clock.instance.count
			for i in range(0, repeats):
				pos += diff
				Board.move(piece, pos)
				await SignalBus.piece_moved
		SpecialAbility.SACRIFICE_ON_CAPTURE:
			if Piece.last_move_capture != null:
				Board.instance.kill_piece(Piece.last_move_piece)
		SpecialAbility.KNIGHT_ON_CAPTURE:
			if Piece.last_move_capture != null:
				await Piece.last_move_piece.transform_into(Piece.Type.KNIGHT)
		SpecialAbility.TransformRook:
			await selected_piece.transform_into(Piece.Type.ROOK)
		SpecialAbility.MoveSamePieceX:
			var additional_moves: int = Clock.instance.count - 1
			for i in range(0, additional_moves):
				await Piece.last_move_piece.move_this(true)
				
				
