extends Sprite2D

@export var OBJECT_TYPE = ""
@export var RECT : Rect2

func _process(delta: float) -> void:
	var texture = AtlasTexture.new()
	texture.atlas = preload("res://res/texture/environment/object_tilemaps.png")
	texture.region = RECT
	self.texture = texture
	
	
	#	if OBJECT_TYPE == "tree":
	#		atlas_texture.region = Rect2(96, 0, 64, 80)
	#	elif OBJECT_TYPE == "tree_medium":
	#		atlas_texture.region = Rect2(64, 0, 32, 64)
	#	elif OBJECT_TYPE == "tree_small":
	#		atlas_texture.region = Rect2(32, 32, 32, 32)
	#	elif OBJECT_TYPE == "tree_sprout":
	#		atlas_texture.region = Rect2(0, 48, 16, 16)
	#	
	#self.texture = atlas_texture

func _on_any_area_entered_object_area(area: Area2D) -> void:
	if area.name == "render_distance":
		self.visible = true
	if area.name == "object_area":
		self.queue_free()

func _on_any_area_exited_object_area(area: Area2D) -> void:
	if area.name == "render_distance":
		self.visible = false
