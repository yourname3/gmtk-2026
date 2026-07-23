extends Node2D
class_name LevelSelect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var dictionary: Dictionary[Vector2i, LevelSelectButton] = {}
	var buttons: Array[LevelSelectButton] = []
	
	for child in get_children():
		if child is LevelSelectButton:
			buttons.append(child)
			dictionary[child.tile()] = child
			
			
	for button in buttons:
		var enabled = false
		var check_neighbor = func(x: int, y: int) -> bool:
			var neighbor = dictionary.get(button.tile() + Vector2i(x, y))
			if neighbor:
				if Global.save_data.completed_levels.has(neighbor.number):
					return true
			return false
		if Global.save_data.completed_levels.has(button.number):
			enabled = true
		if button.number == 0:
			enabled = true # You can always play level 0
		enabled = enabled or check_neighbor.call(-1,  0)
		enabled = enabled or check_neighbor.call( 1,  0)
		enabled = enabled or check_neighbor.call( 0, -1)
		enabled = enabled or check_neighbor.call( 0,  1)
		
		button.visible = enabled
