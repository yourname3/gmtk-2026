extends Node
class_name TheGlobal

var save_data: SaveData = SaveData.new()

var level_names: Array[StringName] = [
	&"levels/transform_rook.tscn",
	&"levels/sacrifice_bishop_staredown.tscn",
]

func load_level(index: int) -> void:
	if index < 0 or index >= level_names.size():
		index = 0
	
	var level := level_names[index]
	ResourceLoader.load_threaded_request(level) # Kick off the request before scene transition
	
	SceneTransition.change_scene_to_path(level)
	
