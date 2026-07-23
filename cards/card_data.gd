extends Resource
class_name CardData

enum Activate {
	PieceMove,
}

var activation: Activate = Activate.PieceMove

func await_activation_full_resolve() -> void:
	if activation == Activate.PieceMove:
		await SignalBus.piece_moved
