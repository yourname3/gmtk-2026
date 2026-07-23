extends Node
class_name TheGlobal

const SINGLE_SAVE_PATH: String = "user://single_save_slot.tres"

var save_data: SaveData = SaveData.new()
var current_level: int = -1

var level_names: Array[StringName] = [
	&"levels/transform_rook.tscn",
	&"levels/sacrifice_bishop_staredown.tscn",
]

func load_level(index: int) -> void:
	if index < 0 or index >= level_names.size():
		index = 0
	
	var level := level_names[index]
	ResourceLoader.load_threaded_request(level) # Kick off the request before scene transition
	
	current_level = index
	SceneTransition.change_scene_to_path(level)
	
func load_save_data() -> void:
	const TYPE_HINT := "SaveData"
	if not ResourceLoader.exists(SINGLE_SAVE_PATH, TYPE_HINT):
		# No save is available, create a default save then return.
		return
	var save = ResourceLoader.load(SINGLE_SAVE_PATH, TYPE_HINT)
	if save == null or save is not SaveData:
		print("Error loading save data. Quit to avoid losing data.")
		return
	save_data = save
	
func save_save_data() -> void:
	var err := ResourceSaver.save(save_data, SINGLE_SAVE_PATH)
	if err != OK:
		print("Error saving save data: ", err)
	
func _ready() -> void:
	load_save_data()
