extends Node2D

signal plot_clicked(plot)

@onready var content_sprite := $ContentSprite
@onready var cover_sprite = $CoverSprite
@onready var matched_sprite = $MatchedSprite

var seed_id := 0
var locked := false

#const COVER_COLOR = Color(0.8, 0.8, 0.8)
const SEED_COLORS = [
	Color(1, 0, 0),   # red
	Color(0, 1, 0),   # green
	Color(0, 0, 1),   # blue
	Color(1, 1, 0),   # yellow
	Color(1, 0.5, 0), # orange
	Color(0, 1, 1),   # cyan
	Color(0.6, 0, 1), # purple
	Color(0, 0, 0)    # black
]

#func _ready():
	#seed_id = randi() % 8
	
func _ready():
	seed_id = randi() % SEED_COLORS.size()
	hide_seed()

func _on_area_2d_input_event(viewport, event, shape_idx):
	if locked:
		return
	if event is InputEventMouseButton and event.pressed:
		print("plot clicked")
		emit_signal("plot_clicked", self)

#func reveal():
	#modulate = Color(1, 1, 1)

func reveal():
	#modulate = Color(1, 1, 0)
	content_sprite.modulate = SEED_COLORS[seed_id]
	content_sprite.visible = true
	cover_sprite.visible = false
	print("seed:", seed_id)

func hide_seed():
	content_sprite.visible = false
	cover_sprite.visible = true
	print("HIDE", seed_id)
	#cover_sprite.modulate = Color(1, 1, 1)
	#modulate = Color(1, 1, 1)
	#modulate = COVER_COLOR


func lock_in():
	locked = true
	cover_sprite.visible = false
	content_sprite.visible = false
	matched_sprite.visible = true
	#content_sprite.modulate = Color(0.3, 0.3, 0.3)
	#modulate = Color(0, 1, 0)
	#modulate = Color(0.3, 0.3, 0.3)
