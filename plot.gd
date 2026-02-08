extends Node2D

signal plot_clicked(plot)

var seed_id := 0
var locked := false

#func _ready():
	#seed_id = randi() % 8

func _on_area_2d_input_event(viewport, event, shape_idx):
	if locked:
		return
	if event is InputEventMouseButton and event.pressed:
		print("plot clicked")
		emit_signal("plot_clicked", self)

#func reveal():
	#modulate = Color(1, 1, 1)

func reveal():
	modulate = Color(1, 1, 0)
	print("seed:", seed_id)

func hide_seed():
	modulate = Color(1, 0, 1)

func lock_in():
	locked = true
	modulate = Color(0, 1, 0)
