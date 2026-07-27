extends Node
class_name TheGlobal

const SINGLE_SAVE_PATH: String = "user://single_save_slot.tres"

var save_data: SaveData = SaveData.new()
var current_level: int = -1

var current_level_label: int = 0

# Used for tracking unlocks this session
var already_completed_levels: Dictionary[int, bool] = {}

var number_levels_previously_won: int = 0

var level_names: Array[StringName] = [
	&"res://levels/level_intro.tscn",# easy enough
	&"res://levels/level_intro_variation.tscn", # easy enough
	&"res://levels/transform_rook.tscn", # not so hard
	&"res://levels/sacrifice_bishop_staredown.tscn", # tricky / harder side
	&"res://levels/careful_xmove_align.tscn", # medium [not ver yhard]
	
	&"res://levels/charge_lineup_variation2.tscn", # < medium ? [still seems easier side]
	&"res://levels/forced_own_kill.tscn", # trickier / harder side of easy/medium
	&"res://levels/level_random1.tscn", # trickier (esp. as compared to careful_xmove_align)
	&"res://levels/pawn_charge1.tscn", # tricky! hard! (first pawn up charge... need to pay attention to these.)
	&"res://levels/rook_laser.tscn", # hard
	
	&"res://levels/transform_rook_variation.tscn", # medium.. harder than other one?
	&"res://levels/random2.tscn", # medium + slight trick (parity)
	&"res://levels/turn_enemy_into_horse_for_movement.tscn", # hard due to pawn charge
	&"res://levels/level_pawnqueen1.tscn", # {medium}
	&"res://levels/pawnqueen2.tscn", # {{new: easy?/}medium}
	
	&"res://levels/card_time_management.tscn", # ?
	&"res://levels/card_time_management_variation.tscn", # prolly harder than card_time_management
	&"res://levels/level_holes.tscn", # technically easier than variation in there are more solutions?
	 # {medium/hard:there is cheese to fix -- do not need gambit card}
	 # do it without vantage as well... if i can remember how to do it without gambit, that is cooler,
	 # although it seems quite hard.
	# solution with no gambit : first charge, then adrenaline to get left guy. then clean up rest with charge + vantage
	&"res://levels/level_holes_variation.tscn", # both {medium} for now # rather hard i think
	&"res://levels/bishops_advance.tscn", # {medium/hard}
	
	&"res://levels/mad_tangle.tscn", # {easy}
	&"res://levels/northward1.tscn", # {easier side of medium}
	&"res://levels/random3.tscn", # {easier}
	&"res://levels/random4.tscn", # {hard}
	&"res://levels/random5.tscn", # {prolly hard - looks very hard on second play}
	
	&"res://levels/random6.tscn", # {medium/hard}
	&"res://levels/xtransform1.tscn", # {medium}
	&"res://levels/big_x.tscn", # {hard? hardest?}
]
func _before_level_load() -> void:
	Piece.reset_statics()
	Card.reset_statics()
	BoardHighlighter.reset_statics()
	

func reload_level() -> void:
	_before_level_load()
	SceneTransition.change_scene_to_path(get_tree().current_scene.scene_file_path)

func load_level(index: int) -> void:
	if index < 0 or index >= level_names.size():
		index = 0
	
	var level := level_names[index]
	ResourceLoader.load_threaded_request(level) # Kick off the request before scene transition
	
	current_level = index
	_before_level_load()
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
	
	number_levels_previously_won = save_data.completed_levels.size()
	already_completed_levels = save_data.completed_levels.duplicate()
	
func save_save_data() -> void:
	var err := ResourceSaver.save(save_data, SINGLE_SAVE_PATH)
	if err != OK:
		print("Error saving save data: ", err)
	
func _ready() -> void:
	print("avail level count = ", level_names.size())
	load_save_data()
	# debug mode: clear save
	# save_data.completed_levels = {}
	
	
	# Initialize music. We will load it when possible.
	ResourceLoader.load_threaded_request("res://music.tscn")
	
var _last_window_mode: Window.Mode = Window.MODE_MAXIMIZED
func toggle_fullscreen() -> void:
	if get_window().mode != Window.MODE_FULLSCREEN:
		_last_window_mode = get_window().mode
		get_window().mode = Window.MODE_FULLSCREEN
	else:
		get_window().mode = _last_window_mode
	
func _process(delta: float) -> void:
	if Music.instance == null:
		var status = ResourceLoader.load_threaded_get_status("res://music.tscn")
		if status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			# instantiate music
			var scene: PackedScene = ResourceLoader.load_threaded_get("res://music.tscn")
			var node = scene.instantiate()
			Music.instance = node
			get_tree().root.add_child(node)
	
	if Input.is_action_just_pressed(&"fullscreen"):
		toggle_fullscreen()
