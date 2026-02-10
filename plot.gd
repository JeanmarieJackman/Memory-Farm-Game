extends Node2D

signal plot_clicked(plot)

#@onready var content_sprite := $ContentSprite
#@onready var cover_sprite = $CoverSprite
#@onready var matched_sprite = $MatchedSprite
@onready var base_tile = $BaseTile
@onready var seed_pack = $SeedPack
@onready var seed_post = $SeedPost
#@onready var crop_stage = $CropStage
@onready var final_crop = $FinalCrop
@onready var crop_stages = [
	$CropStage_UL,
	$CropStage_UR,
	$CropStage_LL,
	$CropStage_LR
]


@export var dirt_texture: Texture2D

enum PlotState { COVERED, REVEALED, MATCHED, WIN }
var state = PlotState.COVERED

func update_visuals():
	base_tile.visible = true
	seed_pack.visible = false
	seed_post.visible = false
	#crop_stage.visible = false
	for c in crop_stages:
		c.visible = false
	final_crop.visible = false

	match state:
		PlotState.COVERED:
			pass
		PlotState.REVEALED:
			seed_pack.visible = true
		PlotState.MATCHED:
			seed_post.visible = true
			#crop_stage.visible = true
			for c in crop_stages:
				c.visible = true
		PlotState.WIN:
			final_crop.visible = true
			#for c in crop_stages:
				#c.visible = false
			#seed_post.visible = false
			
	#match state:
		#PlotState.COVERED, PlotState.REVEALED:
			#base_tile.texture = dirt_texture
#
		#PlotState.MATCHED, PlotState.WIN:
			#base_tile.texture = grass_texture


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
	
#func _ready():
	#seed_id = randi() % SEED_COLORS.size()
	#hide_seed()
	
func _ready():
	state = PlotState.COVERED
	#crop_stages = crop_stage.get_children()
	update_visuals()

func set_seed(id):
	seed_id = id
	hide_seed()

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if locked:
		return
	if event is InputEventMouseButton and event.pressed:
		print("plot clicked")
		emit_signal("plot_clicked", self)

#func reveal():
	#modulate = Color(1, 1, 1)

#func reveal():
	##modulate = Color(1, 1, 0)
	#content_sprite.modulate = SEED_COLORS[seed_id]
	#content_sprite.visible = true
	#cover_sprite.visible = false
	#print("seed:", seed_id)
	
func reveal():
	state = PlotState.REVEALED
	update_visuals()

#func hide_seed():
	#content_sprite.visible = false
	#cover_sprite.visible = true
	#print("HIDE", seed_id)
	##cover_sprite.modulate = Color(1, 1, 1)
	##modulate = Color(1, 1, 1)
	##modulate = COVER_COLOR
	
func hide_seed():
	state = PlotState.COVERED
	update_visuals()

#func lock_in():
	#locked = true
	#cover_sprite.visible = false
	#content_sprite.visible = false
	#matched_sprite.visible = true
	#content_sprite.modulate = Color(0.3, 0.3, 0.3)
	#modulate = Color(0, 1, 0)
	#modulate = Color(0.3, 0.3, 0.3)
	
func lock_in():
	locked = true
	state = PlotState.MATCHED
	update_visuals()
	
func set_win():
	state = PlotState.WIN
	update_visuals()
