extends Node2D

signal plot_clicked(plot)

@onready var base_tile: Sprite2D = $BaseTile
@onready var seed_pack: Sprite2D = $SeedPack
@onready var seed_post: Sprite2D = $SeedPost
@onready var final_crop: Sprite2D = $FinalCrop
@onready var final_shadow: Sprite2D = $FinalCropShadow
@onready var crop_stages: Array[Sprite2D] = [
	$CropStage_UL,
	$CropStage_UR,
	$CropStage_LL,
	$CropStage_LR
]

@export var dirt_texture: Texture2D
@export var crop_data: CropData

enum PlotState { COVERED, REVEALED, MATCHED, WIN, LOSE }

var state = PlotState.COVERED
var seed_id := 0
var locked := false

func _ready():
	print(final_shadow)

	state = PlotState.COVERED
	if crop_data:
		apply_crop_data()
	update_visuals()

func set_seed(id):
	seed_id = id

func apply_crop_data():
	if crop_data == null:
		return

	seed_pack.texture = crop_data.seed_pack
	seed_post.texture = crop_data.seed_post
	crop_stages[0].texture = crop_data.crop_stage_1
	crop_stages[1].texture = crop_data.crop_stage_2
	crop_stages[2].texture = crop_data.crop_stage_3
	crop_stages[3].texture = crop_data.crop_stage_4
	final_crop.texture = crop_data.final_crop
	final_shadow.texture = crop_data.final_crop

	if not seed_pack:
		print("seed_pack null")
	if not seed_post:
		print("seed_post null")
	if not final_crop:
		print("final_crop null")
	for i in crop_stages.size():
		if not crop_stages[i]:
			print("crop_stages ", i, " null")

func update_visuals():
	final_shadow.visible = false
	base_tile.visible = true
	seed_pack.visible = false
	seed_post.visible = false
	final_crop.visible = false

	for c in crop_stages:
		c.visible = false

	match state:
		PlotState.COVERED:
			pass

		PlotState.REVEALED:
			seed_pack.visible = true

		PlotState.MATCHED:
			seed_post.visible = true
			for c in crop_stages:
				c.visible = true

		PlotState.WIN:
			final_shadow.visible = true
			final_shadow.scale = Vector2(7,7)
			seed_post.visible = false
			for c in crop_stages:
				c.texture = crop_data.final_crop
				c.visible = true
			final_crop.visible = true
			final_crop.scale = Vector2(6,6)
			
		PlotState.LOSE:
			if locked:
				seed_post.visible = false
				for c in crop_stages:
					c.visible = true
					c.scale = Vector2(2, 2)
					c.modulate = Color(0.4, 0.25, 0.1)
			else:
				# untouched tiles stay dirt
				for c in crop_stages:
					c.visible = false
				seed_post.visible = false

func reveal():
	state = PlotState.REVEALED
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.8, 0.8), 0.08)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.08)
	
	update_visuals()

func hide_seed():
	state = PlotState.COVERED
	update_visuals()

func lock_in():
	locked = true
	state = PlotState.MATCHED
	update_visuals()

	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.15, 1.15), 0.1)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.1)

func set_growth_stage(stage:int):
	if not crop_data:
		return

	match stage:
		1:
			for c in crop_stages:
				c.texture = crop_data.crop_stage_1
		2:
			for c in crop_stages:
				c.texture = crop_data.crop_stage_2
		3:
			for c in crop_stages:
				c.texture = crop_data.crop_stage_3
		4:
			for c in crop_stages:
				c.texture = crop_data.crop_stage_4

	update_visuals()

func set_win():
	state = PlotState.WIN
	update_visuals()
	
func set_lose():
	state = PlotState.LOSE
	update_visuals()

func set_final_stage():
	state = PlotState.WIN
	seed_post.visible = false
	for c in crop_stages:
		c.texture = crop_data.final_crop
	final_crop.visible = true
	update_visuals()


func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if locked:
		return
	if event is InputEventMouseButton and event.pressed:
		emit_signal("plot_clicked", self)
		
func _on_area_2d_mouse_entered():
	scale = Vector2(1.05, 1.05)

func _on_area_2d_mouse_exited():
	scale = Vector2(1, 1)
