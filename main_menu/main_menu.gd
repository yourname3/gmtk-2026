extends Control
class_name MainMenu

func _ready() -> void:
	%PlayButton.pressed.connect(func():
		SceneTransition.change_scene_to_path(&"res://level_select/level_select.tscn")
	)
