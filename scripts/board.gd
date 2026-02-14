extends Node2D

signal turns_changed(value)

@export var rows := 4
@export var cols := 4
@export var spacing := 220
@export var max_turns := 10
@export var crop_types: Array[CropData]

var remaining_turns := 0
var resolving := false
var plots := []
var first_selected = null
var second_selected = null
var match_count := 0
var growth_stage := 1

@onready var sfx_click: AudioStreamPlayer = $SFX_Click
@onready var sfx_match: AudioStreamPlayer = $SFX_Match
@onready var sfx_miss: AudioStreamPlayer = $SFX_Miss
@onready var sfx_win: AudioStreamPlayer = $SFX_Win
@onready var sfx_lose: AudioStreamPlayer = $SFX_Lose

func _ready():
	remaining_turns = max_turns
	emit_signal("turns_changed", remaining_turns)
	print("Turns:", remaining_turns)
	spawn_grid()
			
func spawn_grid():
	var plot_scene = preload("res://plot.tscn")

	var total_plots = rows * cols
	@warning_ignore("integer_division")
	var seed_pairs = total_plots / 2
	var seeds = []

	for i in range(seed_pairs):
		seeds.append(i)
		seeds.append(i)

	seeds.shuffle()

	var index = 0
	for r in range(rows):
		for c in range(cols):
			var plot = plot_scene.instantiate()
			plot.position = Vector2(c * spacing, r * spacing)

			add_child(plot)  # IMPORTANT: must be before using onready vars

			var seed_id = seeds[index]
			index += 1

			plot.set_seed(seed_id)

			if seed_id < crop_types.size():
				plot.crop_data = crop_types[seed_id]
				plot.apply_crop_data()

			plot.connect("plot_clicked", _on_plot_clicked)
			plots.append(plot)
		
func _on_plot_clicked(plot):
	if resolving:
		return
		
	if first_selected == null:
		first_selected = plot
		plot.reveal()
		sfx_click.play()

	elif second_selected == null and plot != first_selected:
		second_selected = plot
		plot.reveal()
		remaining_turns -= 1
		emit_signal("turns_changed", remaining_turns)
		print("Turns:", remaining_turns)
		resolving = true
		check_match()

func check_match():
	if first_selected.seed_id == second_selected.seed_id:
		first_selected.lock_in()
		second_selected.lock_in()
		sfx_match.play()
		
		match_count += 1
		update_growth_stage()
	
	else:
		sfx_miss.play()
		await get_tree().create_timer(0.75).timeout
		first_selected.hide_seed()
		second_selected.hide_seed()

	first_selected = null
	second_selected = null
	resolving = false
	
	if remaining_turns <= 0:
		sfx_lose.play()
		print("LOSE")
		for p in plots:
			p.set_lose()
		await get_tree().create_timer(1.0).timeout
		get_tree().paused = true
	elif all_matched():
		sfx_win.play()
		print("WIN")
		for p in plots:
			#p.set_win()
			p.set_final_stage()
		await get_tree().create_timer(1.0).timeout
		get_tree().paused = true

func all_matched():
	for p in plots:
		if not p.locked:
			return false
	return true
	
func update_growth_stage():
	match match_count:
		3:
			growth_stage = 2
		5:
			growth_stage = 3
		7:
			growth_stage = 4

	for p in plots:
		if p.locked:
			p.set_growth_stage(growth_stage)
