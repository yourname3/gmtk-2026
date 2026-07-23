extends Camera2D
class_name LevelCamera

func _process(dt:float) -> void:
	var board := %ChessBoard
	var hand: CardHand = %CardHand
	var hand_h: float = hand.get_height()
	var tiles: Rect2i = board.get_used_rect()
	
	var margin_x = 128
	var margin_y = 32
	
	var width: float = tiles.size.x * 256.0 + margin_x * 2.0
	var height: float = tiles.size.y * 256.0 + margin_y * 2.0 #+ hand_h
	
	var viewport = get_viewport_rect()
	viewport.size.y -= hand_h
	viewport.size.x -= 512 # get some extra room width-wise
	var zoom_x: float = viewport.size.x / width
	var zoom_y: float = viewport.size.y / height
	
	zoom = min(zoom_x, zoom_y) * Vector2.ONE
	position = Vector2(width / 2 - margin_x, height / 2 - margin_y)
	
	offset.y = hand_h / (2.0 * zoom.y)
	
	#hand.move_to_align_bottom_y_with(viewport.size.y / zoom.y - margin_y * 2)
