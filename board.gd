extends Node2D

@export var rows := 4
@export var cols := 4
@export var spacing := 120

var plots := []
var first_selected = null
var second_selected = null

func _ready():
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

func _on_plot_clicked(plot):
	if first_selected == null:
		first_selected = plot
		plot.reveal()
	elif second_selected == null and plot != first_selected:
		second_selected = plot
		plot.reveal()
		check_match()

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
