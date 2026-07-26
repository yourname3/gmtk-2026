extends RichTextLabel
class_name LevelSelectSticky

const F = "[font=res://level_select/todo_font.tres][font_size=42]"
const C = "[/font_size][/font]"

var animals := ["dog", "cat", "owl", "pig", "horse", "goat", "llama", "donkey", "rat"]

var chores := ["Buy groceries", 
"Go to dentist",
"Do laundry",
"Finish game jam",
"Get haircut",
"Find keys",
"Throw party",
"Make a sandwich",
"Solve mystery",
"Paint the carpet",
"Peel oranges",
"Vacuum the table"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var chosen = []
	
	var chore_count = randi_range(2, 4)
	if randf() < 0.3: # animal chore
		chore_count -= 1
		chosen.append("Feed the " + animals.pick_random())
	
	chores.shuffle()
	for i in range(chore_count):
		chosen.append(chores[i])
		
	chosen.shuffle()
	
	var levels_remaining = 28 - Global.save_data.completed_levels.size()
	
	text = str(F, ["Todo list", "To do", "Todo", "To do list"].pick_random(), "\n\n")
	if levels_remaining > 0:
		var s = "s"
		if levels_remaining == 1:
			s = ""
		text += str(C, levels_remaining, F, " puzzle", s, "\n\n")
	
	for c in chosen:
		text += c + "\n\n"

	text += C

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
