extends Node2D

@onready var noise : Noise

@onready var world_seed : int = 4803
@onready var world_size : int = 512

@export var test : NoiseTexture2D


func _ready():
	noise = FastNoiseLite.new()
	
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.seed = world_seed
	noise.frequency = 0.25
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 5
	noise.fractal_gain = 0.45
	noise.fractal_lacunarity = 1.875
	
	return noise
	
#func falloff(distance, radius):
	#return smoothstep(distance * 0.75, radius, distance)

func tile(x, y, atlas_coords: Vector2):
	$tilemap_land.set_cell(Vector2(x, y), 1, atlas_coords)

func _draw() -> void:
	var size = world_size
	var radius = size / 2
	var index : int
	var a
	
	for y in range(size):
		for x in range(size):
			var dx = x - radius
			var dy = y - radius
			var distance = sqrt(dx * dx + dy * dy)
			
			var falloff_value = 1.0 - smoothstep(size / 4, size / 2, distance)
			var noise_value = noise.get_noise_2d(x * 0.04, y * 0.04)# * falloff_value + noise.get_noise_2d(x * 0.02, y * 0.02) * 0.2
			var final_value = noise_value * falloff_value
			a = final_value
			
			if a < 0.001:
				pass
			elif a < 0.01:
				tile(x, y, Vector2(0, 1))
			elif a < 0.175:
				tile(x, y, Vector2(2, 1))
			else:
				tile(x, y, Vector2(4, 1))
			
			#DISABLEDif a < 0.001:
			#DISABLED	pass
			#DISABLED#elif a < 0.002:
			#DISABLED#	tile(x, y, Vector2(1, 0))
			#DISABLED#elif a < 0.004:
			#DISABLED#	tile(x, y, Vector2(2, 0))
			#DISABLED#elif a < 0.006:
			#DISABLED#	tile(x, y, Vector2(3, 0))
			#DISABLEDelif a < 0.008:
			#DISABLED	tile(x, y, Vector2(4, 0))
			#DISABLEDelif a < 0.01:
			#DISABLED	tile(x, y, Vector2(5, 0))
			#DISABLEDelif a < 0.02:
			#DISABLED	tile(x, y, Vector2(0, 1)) #sand i guess
			#DISABLEDelif a < 0.04:
			#DISABLED	tile(x, y, Vector2(1, 1)) # land
			#DISABLEDelif a < 0.06:
			#DISABLED	tile(x, y, Vector2(2, 1))
			#DISABLEDelif a < 0.08:
			#DISABLED	tile(x, y, Vector2(3, 1))
			#DISABLEDelif a < 0.1:
			#DISABLED	tile(x, y, Vector2(4, 1))
			#DISABLEDelif a < 0.2:
			#DISABLED	tile(x, y, Vector2(5, 1))
			#DISABLEDelif a < 0.4:
			#DISABLED	tile(x, y, Vector2(0, 0))
			#DISABLEDelif a < 0.5:
			#DISABLED	tile(x, y, Vector2(0, 2))
			#DISABLEDelif a < 0.8:
			#DISABLED	tile(x, y, Vector2(1, 2))
			#DISABLEDelse:
			#DISABLED	tile(x, y, Vector2(2, 2))
			
			#if final_value < 0.001:
			#	pass
			#elif final_value < 0.05:
			#		tile(x, y, Vector2(2, 5)) #sea
			#elif final_value < 0.09:
			#		tile(x, y, Vector2(6, 1)) #shore
			#elif final_value > 0.09:
			#	tile(x, y, Vector2(2, 1)) #land
			#else:
			#	pass
			#	#tile(x, y, Vector2(0, 7))
	
	var empty_coord = Vector2i(-1, -1)
	var grass_coord = Vector2i(2, 1)
	var sand_coord = Vector2i(0, 1)
	
	corrosion()
	smoothing_terrain(sand_coord, empty_coord, Vector2(3, 2), 8)
	replace_standalone_tile(empty_coord, Vector2(3, 2))
	
func smooth(target, object: Vector2):
	var size = world_size
	var land_side = 0
	var empty_coord = Vector2i(-1, -1)
	
	for y in range(size):
		for x in range(size):
			if $tilemap_land.get_cell_atlas_coords(Vector2i(x, y)) == target:
				if $tilemap_land.get_cell_atlas_coords(Vector2i(x + 1, y)) == empty_coord:
					land_side += 1
				if $tilemap_land.get_cell_atlas_coords(Vector2i(x - 1, y)) == empty_coord:
					land_side += 1
				if $tilemap_land.get_cell_atlas_coords(Vector2i(x, y + 1)) == empty_coord:
					land_side += 1
				if $tilemap_land.get_cell_atlas_coords(Vector2i(x, y - 1)) == empty_coord:
					land_side += 1
				if land_side == 3:
					tile(x, y, object)
					land_side = 0

func smoothing_terrain(target: Vector2i, near_target: Vector2i, object: Vector2, stroke_size: int):
	var size = world_size
	for y in range(size):
		for x in range(size):
			#land to sand
			if $tilemap_land.get_cell_atlas_coords(Vector2i(x, y)) == target:
				if $tilemap_land.get_cell_atlas_coords(Vector2i(x + stroke_size, y)) == near_target:
					tile(x + stroke_size, y, object)
				if $tilemap_land.get_cell_atlas_coords(Vector2i(x - stroke_size, y)) == near_target:
					tile(x - stroke_size, y, object)
				if $tilemap_land.get_cell_atlas_coords(Vector2i(x, y + stroke_size)) == near_target:
					tile(x, y + stroke_size, object)
				if $tilemap_land.get_cell_atlas_coords(Vector2i(x, y - stroke_size)) == near_target:
					tile(x, y - stroke_size, object)
					
				if $tilemap_land.get_cell_atlas_coords(Vector2i(x + stroke_size / 2, y + stroke_size / 2)) == near_target:
					tile(x + stroke_size / 2, y + stroke_size / 2, object)
				if $tilemap_land.get_cell_atlas_coords(Vector2i(x - stroke_size / 2, y - stroke_size / 2)) == near_target:
					tile(x - stroke_size / 2, y - stroke_size / 2, object)
				if $tilemap_land.get_cell_atlas_coords(Vector2i(x - stroke_size / 2, y + stroke_size / 2)) == near_target:
					tile(x - stroke_size / 2, y + stroke_size / 2, object)
				if $tilemap_land.get_cell_atlas_coords(Vector2i(x + stroke_size / 2, y - stroke_size / 2)) == near_target:
					tile(x + stroke_size / 2, y - stroke_size / 2, object)

func tile_get_cell(atlas_coords: Vector2i):
	return $tilemap_land.get_cell_atlas_coords(atlas_coords)
	
func replace_standalone_tile(target_find, target_replace):
	var size = world_size
	for y in range(size):
		for x in range(size):
			var side = 0
			if tile_get_cell(Vector2i(x, y)) == target_find:
				if tile_get_cell(Vector2i(x, y + 1)) != target_find:
					side += 1
				if tile_get_cell(Vector2i(x, y - 1)) != target_find:
					side += 1
				if tile_get_cell(Vector2i(x + 1, y)) != target_find:
					side += 1
				if tile_get_cell(Vector2i(x - 1, y)) != target_find:
					side += 1
				
				if side >= 3:
					tile(x, y, target_replace)
			
	pass

func corrosion():
	var size = world_size
	var empty_coord = Vector2i(-1, -1)
	var grass_coord = Vector2i(2, 1)
	var sand_coord = Vector2i(0, 1)
	
	var stroke_size = 6
	
	#smooth(grass_coord, Vector2(0, 1))
	#smooth(sand_coord, Vector2(-1, -1))
	
	for y in range(size):
		for x in range(size):
			#land to sand
			if $tilemap_land.get_cell_atlas_coords(Vector2i(x, y)) == grass_coord:
				if $tilemap_land.get_cell_atlas_coords(Vector2i(x + stroke_size, y)) == empty_coord:
					tile(x + stroke_size, y, Vector2(0, 1))
				if $tilemap_land.get_cell_atlas_coords(Vector2i(x - stroke_size, y)) == empty_coord:
					tile(x - stroke_size, y, Vector2(0, 1))
				if $tilemap_land.get_cell_atlas_coords(Vector2i(x, y + stroke_size)) == empty_coord:
					tile(x, y + stroke_size, Vector2(0, 1))
				if $tilemap_land.get_cell_atlas_coords(Vector2i(x, y - stroke_size)) == empty_coord:
					tile(x, y - stroke_size, Vector2(0, 1))
					
				if $tilemap_land.get_cell_atlas_coords(Vector2i(x + stroke_size / 2, y + stroke_size / 2)) == empty_coord:
					tile(x + stroke_size / 2, y + stroke_size / 2, Vector2(0, 1))
				if $tilemap_land.get_cell_atlas_coords(Vector2i(x - stroke_size / 2, y - stroke_size / 2)) == empty_coord:
					tile(x - stroke_size / 2, y - stroke_size / 2, Vector2(0, 1))
				if $tilemap_land.get_cell_atlas_coords(Vector2i(x - stroke_size / 2, y + stroke_size / 2)) == empty_coord:
					tile(x - stroke_size / 2, y + stroke_size / 2, Vector2(0, 1))
				if $tilemap_land.get_cell_atlas_coords(Vector2i(x + stroke_size / 2, y - stroke_size / 2)) == empty_coord:
					tile(x + stroke_size / 2, y - stroke_size / 2, Vector2(0, 1))
	
	


func _process(delta: float) -> void:
	var speed = 10
	if Input.is_action_pressed("ui_down"):
		$cam.position.y += speed
	if Input.is_action_pressed("ui_up"):
		$cam.position.y -= speed
	if Input.is_action_pressed("ui_left"):
		$cam.position.x -= speed
	if Input.is_action_pressed("ui_right"):
		$cam.position.x += speed
	
	if Input.is_action_just_pressed("zoom_in"):
		$cam.zoom -= Vector2(0.1, 0.1)
	if Input.is_action_just_pressed("zoom_out"):
		$cam.zoom += Vector2(0.1, 0.1)
		
		
