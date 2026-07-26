extends Node2D
class_name LevelSelect

var buttons: Array[LevelSelectButton] = []

# on first load, we don't show the unlock animation.
static var first_load: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var dictionary: Dictionary[Vector2i, LevelSelectButton] = {}
	%ChessBoard.hide()
	
	for child in get_children():
		if child is LevelSelectButton:
			buttons.append(child)
			dictionary[child.tile()] = child
			
	var board_offset: int = 0
	for button in buttons: # assign board texture offsets
		button.board_offset = board_offset
		board_offset = (board_offset + 1) % 16
			
	var newly_unlocked_arr: Array[LevelSelectButton] = []
			
	for button in buttons:
		var enabled = false
		var newly_unlocked = false
		var check_neighbor = func(x: int, y: int) -> bool:
			var neighbor = dictionary.get(button.tile() + Vector2i(x, y))
			if neighbor:
				if Global.save_data.level_completed(neighbor.number):
					return true
			return false
		if Global.save_data.level_completed(button.number):
			enabled = true
		if button.number == 0:
			enabled = true # You can always play level 0
		enabled = enabled or check_neighbor.call(-1,  0)
		enabled = enabled or check_neighbor.call( 1,  0)
		enabled = enabled or check_neighbor.call( 0, -1)
		enabled = enabled or check_neighbor.call( 0,  1)
		
		if enabled:
			newly_unlocked = not Global.already_completed_levels.has(button.number)
		
		button.visible = enabled and (not newly_unlocked or first_load)
		if newly_unlocked:
			newly_unlocked_arr.append(button)
			Global.already_completed_levels[button.number] = true
			
	if first_load:
		first_load = false
	else:
		for button in newly_unlocked_arr:
			await button.reveal()

func disable_all_buttons() -> void:
	for button in buttons:
		button.disabled = true
