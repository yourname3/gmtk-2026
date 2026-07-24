extends Node
class_name TheGlobal

const SINGLE_SAVE_PATH: String = "user://single_save_slot.tres"

var save_data: SaveData = SaveData.new()
var current_level: int = -1

var level_names: Array[StringName] = [
	&"res://levels/level_intro.tscn",# easy enough
	&"res://levels/level_intro_variation.tscn", # easy enough
	&"res://levels/transform_rook.tscn", # not so hard
	&"res://levels/sacrifice_bishop_staredown.tscn", # tricky
	&"res://levels/careful_xmove_align.tscn", # medium
	&"res://levels/charge_lineup_variation2.tscn", # < medium ?
	&"res://levels/forced_own_kill.tscn", # trickier
	&"res://levels/level_random1.tscn", # trickier (esp. as compared to careful_xmove_align)
	&"res://levels/pawn_charge1.tscn", # tricky! hard! (first pawn up charge... need to pay attention to these.)
	&"res://levels/rook_laser.tscn", # hard
	&"res://levels/transform_rook_variation.tscn", # medium.. harder than other one?
	&"res://levels/random2.tscn", # medium + slight trick (parity)
	&"res://levels/turn_enemy_into_horse_for_movement.tscn", # hard due to pawn charge
	&"res://levels/level_pawnqueen1.tscn", # {medium}
	&"res://levels/pawnqueen2.tscn", # {medium}
	&"res://levels/card_time_management.tscn", # ?
	&"res://levels/card_time_management_variation.tscn", # prolly harder than card_time_management
	&"res://levels/level_holes.tscn", # technically easier than variation in there are more solutions?
	&"res://levels/level_holes_variation.tscn", # both {medium} for now
	&"res://levels/bishops_advance.tscn", # {medium}
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
