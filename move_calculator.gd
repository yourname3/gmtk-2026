extends RefCounted
class_name MoveCalculator

var capture_black: bool = false
var capture_white: bool = false

var moves: Array[Vector2i] = []

func add(move: Vector2i, piece: Piece, require_capturable: bool = false) -> bool:
	var allow_further_moves: bool = true
	
	if piece != null:
		# Filter based on piece
		if piece.is_black and not capture_black: return false
		if not piece.is_black and not capture_white: return false
		
		# we hit a piece, stop allowing moves in general
		allow_further_moves = false
	elif require_capturable:
		# Require capturable and null piece, so return false without adding.
		return false
		
	moves.append(move)
	return allow_further_moves
