extends Node2D
class_name LevelSelect

var buttons: Array[LevelSelectButton] = []
var button_map: Dictionary[Vector2i, LevelSelectButton] = {}

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
			
	button_map = dictionary
			
	var board_offset: int = 0
	for button in buttons: # assign board texture offsets
		button.board_offset = board_offset
		board_offset = (board_offset + 1) % 16
			
	var newly_unlocked_arr: Array[LevelSelectButton] = []
	
	var level_count := Global.level_names.size()
	var all_levels_completed = Global.save_data.completed_levels.size() >= level_count
	var all_levels_were_completed = Global.number_levels_previously_won >= level_count
			
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
		button.unlocked = enabled
		if newly_unlocked:
			newly_unlocked_arr.append(button)
			Global.already_completed_levels[button.number] = true
			
	if first_load:
		first_load = false
	else:
		for button in newly_unlocked_arr:
			await button.reveal()
			
	if all_levels_completed:
		if not all_levels_were_completed:
			%Medal.show()
			%MedalAnim.play(&"reveal")
			%UnlockShimmer.play()
		else:
			%Medal.show()
	else:
		%Medal.hide()
		
	Global.number_levels_previously_won = Global.save_data.completed_levels.size()

func disable_all_buttons() -> void:
	for button in buttons:
		button.disabled = true
