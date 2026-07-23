extends CanvasLayer
class_name TheSceneTransition

var next_scene: StringName = &"<avail>"

const COLOR_ONE = Color("#aa8f6f")
const COLOR_TWO = Color("#463b2e")

func change_scene_to_path(path: StringName) -> void:
	if next_scene != &"<avail>":
		return
	
	var size = get_viewport().get_visible_rect().size
	
	var x = 64
	var xi: int = 0
	while x - 64 < size.x:
		var y = 64
		var yi: int = 0
		while y - 64 < size.y:
			var square: SceneTransitionSquare = preload("res://scene_transition/scene_transition_square.tscn").instantiate()
			square.position = Vector2(x, y)
			square.delay = float(xi + yi) * 0.02
			square.rotation_degrees = -45 + float(xi + yi) * -5
			# square.region_rect.position.x = 256 * ((xi + yi) % 2)
			square.modulate = COLOR_ONE if ((xi + yi) % 2) == 0 else COLOR_TWO
			add_child(square)
			y += 128
			yi += 1
		x += 128
		xi += 1

	var node = null
		
	for child in get_children():
		while not child.done:
			await get_tree().process_frame
		
		if node == null:
			var try: PackedScene = ResourceLoader.load_threaded_get(path)
			if try != null:
				node = try.instantiate()
		
	if node == null:
		print("later load")
		node = load(path).instantiate()
	#var try = ResourceLoader.load_threaded_get(path)
	#if try == null:
		#print("no threaded get")
		#try = load(path)
	get_tree().change_scene_to_node(node)
	await get_tree().create_timer(0.2, true).timeout
	
	for child in get_children():
		child.second_anim()
