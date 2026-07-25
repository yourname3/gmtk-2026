extends Node2D
class_name ChessboardParticleSystem

var tile_w := 0
var tile_b := 0

@export var decay_time := 2.0
@export var extra_time := 0.3

func incr_tile(t: int) -> int:
	return (t + 1) % 16
func get_tile(t: int, color: bool) -> Vector2:
	var row: int = t / 4
	var col: int = (t % 4) * 2 + (1 if color else 0)
	return Vector2(col, row) * 256

func spawn_column(color: bool, advance: float = 0.0) -> void:
	var scale_ := 0.3
	var height: float = 256 * sqrt(2) * scale_
	var y: float  = height * 0.5
	if color: y = 0
	var total: float = get_viewport_rect().size.y
	
	var advance_scale_t := (advance - extra_time) / (decay_time + extra_time)
	advance_scale_t = clampf(advance_scale_t, 0.0, 1.0)
	scale_ = lerp(scale_, 0.0, advance_scale_t)
	
	var et := extra_time
	var dt := decay_time
	et -= advance
	if et < 0:
		dt += et
		et = 0 # not perfect for some reason... not sure we care
	
	while y <= total:
		var particle := preload("res://main_menu/chessboard_particle.tscn").instantiate()
		particle.position = Vector2(0, y)
		particle.scale = scale_ * Vector2.ONE
		particle.rotation_degrees = 45
		particle.region_rect.position = get_tile(tile_b if color else tile_w, color)
		
		particle.height = height
		particle.decay_time = dt
		particle.extra_time = et
		
		particle.position.x += height * advance
		
		if color: tile_b = incr_tile(tile_b)
		else: tile_w = incr_tile(tile_w)
		#color = not color
		y += height
		
		add_child(particle)
		

func preprocess() -> bool:
	var color := false
	var time := 0.0
	var total_time := decay_time + extra_time
	while time < total_time:
		spawn_column(color, total_time - time)
		color = not color
		time += 0.5
	return color

func _ready() -> void:
	var color := preprocess()
	while true:
		spawn_column(color)
		await get_tree().create_timer(0.5, false).timeout
		color = not color
