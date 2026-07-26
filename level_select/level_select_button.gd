@tool
extends Button
class_name LevelSelectButton

## Now no longer used as index, but as the "name" of the level (from previous versions)
@export var level_number: int = 1
## Display number
@export var display_number: int = 1

@onready var number = level_number - 1

var newly_unlocked: bool = false
var board_offset: int = 0 # offset used for computing region, 0-15

func tile() -> Vector2i:
	return Vector2i(position / 256)
	
func reveal() -> void:
	%UnlockShimmer.play()
	%AnimationPlayer.play(&"reveal")
	await %AnimationPlayer.animation_finished

const NOT_WON_COLOR: Color = Color("ababab79")
const WON_LINE: Color = Color("43a000")
const WON_FILL: Color = Color("3b5d25")

func _ready() -> void:
	#super._ready()
	mouse_entered.connect(func(): ButtonSFX.hover.play())
	
	%Label.text = str(display_number)
	text = ""
	if Engine.is_editor_hint(): return
	
	pressed.connect(func():
		%Selected.play_floating()
		ButtonSFX.click.play()
		get_parent().disable_all_buttons()
		Global.load_level(number)
	)
	
	var t := tile()
	var tile_column = ((t.x + t.y) % 2 + 2) % 2
	
	if tile_column == 0:
		%BoardTile.rotation = TAU / 4
	
	var tile_row: int = (board_offset / 4)
	tile_column += (board_offset % 4) * 2
	
	%BoardTile.region_rect.position = Vector2(tile_column, tile_row) * 256
	
	
	#print("me: ", number, " completed: ", Global.save_data.level_completed(number))
	if Global.save_data.level_completed(number):
		%Piece.self_modulate = WON_FILL
		%Piece.material.set_shader_parameter(&"line_colour", WON_LINE)
		#%Label.add_theme_color_override(&"font_color", WON_LINE)
	else:
		%Piece.self_modulate = Color.TRANSPARENT
		%Piece.material.set_shader_parameter(&"line_colour", NOT_WON_COLOR)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		%Label.text = str(display_number)
		text = str(" ", level_number)
