extends Node2D

signal turns_changed(value)

@export var rows := 4
@export var cols := 4
@export var spacing := 120
@export var max_turns := 160
var remaining_turns := 0
var resolving := false


var plots := []
var first_selected = null
var second_selected = null
#var seed_pool := []

#func generate_seeds():
	#seed_pool.clear()
	#for i in range(8):
		#seed_pool.append(i)
		#seed_pool.append(i)
	#seed_pool.shuffle()


func _ready():
	remaining_turns = max_turns
	emit_signal("turns_changed", remaining_turns)
	print("Turns:", remaining_turns)
	spawn_grid()


#func spawn_grid():
	#var plot_scene = preload("res://plot.tscn")
	#for r in range(rows):
		#for c in range(cols):
			#var plot = plot_scene.instantiate()
			#plot.position = Vector2(c * spacing, r * spacing)
			#add_child(plot)
			#plot.connect("plot_clicked", _on_plot_clicked)
			#plots.append(plot)

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
			plot.seed_id = seeds[index]
			index += 1
			add_child(plot)
			plot.connect("plot_clicked", _on_plot_clicked)
			plots.append(plot)
			
	#generate_seeds()
	#
	#var index := 0
#
	#for r in range(rows):
		#for c in range(cols):
			#var plot = plot_scene.instantiate()
			#plot.position = Vector2(c * spacing, r * spacing)
			#plot.seed_id = seed_pool[index]
			#index += 1
			#add_child(plot)
			#plot.connect("plot_clicked", _on_plot_clicked)
			#plots.append(plot)


#func _on_plot_clicked(plot):
	#if first_selected == null:
		#first_selected = plot
		#plot.reveal()
	#elif second_selected == null and plot != first_selected:
		#second_selected = plot
		#plot.reveal()
		#remaining_turns -= 1
		#print("Turns:", remaining_turns)
		#check_match()
		
func _on_plot_clicked(plot):
	if resolving:
		return

	if first_selected == null:
		first_selected = plot
		plot.reveal()
	elif second_selected == null and plot != first_selected:
		second_selected = plot
		plot.reveal()
		remaining_turns -= 1
		emit_signal("turns_changed", remaining_turns)
		print("Turns:", remaining_turns)
		resolving = true
		check_match()
		
#func _on_board_turns_changed(value):
	##print(get_tree().current_scene.get_children())
	#var canvas = $CanvasLayer
	#print(canvas.get_children())
	##$CanvasLayer/TurnsLabel.text = "Turns: %d" % value

#func check_match():
	#if first_selected.seed_id == second_selected.seed_id:
		#first_selected.lock_in()
		#second_selected.lock_in()
	#else:
		#await get_tree().create_timer(0.5).timeout
		#first_selected.hide_seed()
		#second_selected.hide_seed()
	#first_selected = null
	#second_selected = null
	#if remaining_turns <= 0:
		#print("LOSE")
		#get_tree().paused = true
	#if all_matched():
		#print("WIN")
		#get_tree().paused = true

func check_match():
	if first_selected.seed_id == second_selected.seed_id:
		first_selected.lock_in()
		second_selected.lock_in()
	else:
		await get_tree().create_timer(0.5).timeout
		first_selected.hide_seed()
		second_selected.hide_seed()

	first_selected = null
	second_selected = null
	resolving = false
	
	if remaining_turns <= 0:
		print("LOSE")
		get_tree().paused = true
	elif all_matched():
		print("WIN")
		for p in plots:
			p.set_win()
		get_tree().paused = true

func all_matched():
	for p in plots:
		if not p.locked:
			return false
	return true
