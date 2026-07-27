extends Node2D
class_name Clock

@onready var clock := %Clock

static var instance: Clock = null

var count: int = 0

func button_sounds(b: TextureButton) -> void:
	b.pressed.connect(func(): %Click.play())
	b.mouse_entered.connect(func(): %Hover.play())

func _ready() -> void:
	instance = self
	
	button_sounds(%PauseButton)
	button_sounds(%RetryButton)
	
	%PauseButton.pressed.connect(func():
		PauseMenu.instance.pause()
	)
	%RetryButton.pressed.connect(func():
		Global.reload_level()
	)

func _anim_update_clock() -> void:
	clock.text = str(count)
	
func update(cards: int, initial: bool = false) -> void:
	if count != cards:
		%ClockFuture.text = str(cards)
		count = cards
		if not initial:
			await get_tree().create_timer(0.1, false).timeout
		%AnimationPlayer.play(&"flip")
		if not initial:
			%SplitFlapSFX.play()
	else:
		count = cards
	
