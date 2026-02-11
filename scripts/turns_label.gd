extends Label

func _on_board_turns_changed(value):
	text = "Turns: %d" % value
