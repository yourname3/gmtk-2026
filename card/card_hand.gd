extends Node2D
class_name CardHand

var active_cards: Array[Card] = []

@export var cards: Array[CardData] = []

# Applies any relevant state updates when a new card becomes "selected" for real.
func select_card(card: Card) -> void:
	if card != Card.selected_card: # Reset board selection for now..
		if BoardHighlighter.select_state == BoardHighlighter.SelectState.LOCATION:
			SignalBus.move_selected.emit(null)
	Card.selected_card = card
	
	var set_select_state := false
	
	if Card.is_activated_on_piece_move():
		if BoardHighlighter.select_state != BoardHighlighter.SelectState.LOCATION: # Todo...
			BoardHighlighter.select_state = BoardHighlighter.SelectState.PIECE
		set_select_state = true
		
	if Card.is_activated_on_piece_select():
		BoardHighlighter.select_state = BoardHighlighter.SelectState.PIECE_ONLY
		set_select_state = true
		
	if not set_select_state:
		# Reset to NONE

		BoardHighlighter.select_state = BoardHighlighter.SelectState.NONE
		
	BoardHighlighter.select_filter = card.data.piece_filter

func arrange_cards() -> void:
	const w: float = 384
	const phi: float = 0.04
	var total_w: float = (active_cards.size() * w)
	var cur_x: float = -total_w / 2 + w / 2
	
	var total_phi: float = (active_cards.size() * phi)
	var cur_angle: float = -total_phi / 2 + phi /2
	
	#var i = -get_child_count() / 2
	
	var mouse := get_local_mouse_position()
	var closest: Card = null
	var closest_dist: float = INF
	
	var select_dist_threshold: float = 128 * 8
	
	#Card.highlighted_card = null
	for child: Card in active_cards:
		child.target_position.y = cur_x * sin(cur_angle)
		child.target_position.x = cur_x
		
		child.target_rotation = cur_angle
		
		cur_x += w
		cur_angle += phi
		
		var dist := child.target_position.distance_squared_to(mouse)
		if dist < closest_dist:
			closest = child
			closest_dist = dist
			
	if Engine.is_editor_hint(): return
	
	var mouse_valid: bool = %RefRect.get_rect().has_point(mouse)
			
	if mouse_valid and not Card.card_playing:#mouse.y > (-768 / 2) + 30 and not Card.card_playing:
		if closest_dist < select_dist_threshold * select_dist_threshold:
			Card.highlighted_card = closest
			if not Card.selected_hard:
				select_card(Card.highlighted_card)
			if Input.is_action_just_pressed("select_card"):
				# TODO: Consider making this some sort of _unhandled_input instead
				if Card.selected_hard and Card.selected_card == Card.highlighted_card:
					Card.selected_hard = false
				else:
					Card.selected_hard = true
					select_card(Card.highlighted_card)
					
	if not mouse_valid:
		Card.highlighted_card = null
		
func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	SignalBus.card_played.connect(func(card: Card):
		active_cards.erase(card)
	)
	
	for child in get_children():
		if child is Card:
			active_cards.push_back(child)
			
	for card in cards:
		var c: Card = preload("res://card/card.tscn").instantiate()
		c.data = card
		add_child(c)
		active_cards.push_back(c)
	
	arrange_cards()
	
	if active_cards.size() > 0:
		select_card(active_cards[0])
	
	SignalBus.card_finished_playing.connect(func():
		Clock.instance.update(active_cards.size())
		
		await get_tree().process_frame
		if Card.selected_card == null:
			for child in active_cards:
				if not child.is_queued_for_deletion():
					select_card(child)
					break
	)
	
	await get_tree().process_frame
	await get_tree().process_frame
	Clock.instance.update(active_cards.size())
	
func get_height() -> float:
	return %RefRect.get_rect().size.y
	
func move_to_align_bottom_y_with(desired_bottom_y: float) -> void:
	position.y = desired_bottom_y - %RefRect.get_rect().size.y - %RefRect.position.y

func _process(delta: float) -> void:
	#if Engine.is_editor_hint():
	arrange_cards()
		#return
