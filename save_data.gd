extends Resource
class_name SaveData

@export var completed_levels: Dictionary[int, bool] = {}

func level_completed(idx: int) -> bool:
	return true # debug mode
	#return completed_levels.has(idx)
