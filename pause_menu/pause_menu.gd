extends Control
class_name PauseMenu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	
	%Resume.pressed.connect(unpause)
	%LevelSelect.pressed.connect(func():
		SceneTransition.change_scene_to_path(&"res://level_select/level_select.tscn")
	)
	%MainMenu.pressed.connect(func():
		SceneTransition.change_scene_to_path(&"res://main_menu/main_menu.tscn")
	)
	if OS.has_feature("web"):
		# Disable quite button on web
		%Quit.hide()
	else:
		%Quit.pressed.connect(func():
			get_tree().quit()
		)

func pause() -> void:
	%AnimationPlayer.play(&"open")
	get_tree().paused = true
func unpause() -> void:
	%AnimationPlayer.play(&"close")
	get_tree().paused = false

func toggle_pause() -> void:
	if get_tree().paused:
		unpause()
	else:
		pause()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed(&"pause"):
		toggle_pause()
