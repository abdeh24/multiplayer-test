extends Node2D

@onready var world_seed:= 4803
@onready var world_size:= 512
@onready var world_gen:= 'v1'

@onready var ground = $ground
@onready var environment = $environment

@onready var noise: Noise
@onready var peer = ENetMultiplayerPeer

@export var player_base:= PackedScene
@export var noise_height_text: NoiseTexture2D

@onready var temp_array: Array

func noise_generation(random_seed:= false):
	var world_center
	var world_radius
	var falloff_power
	if world_gen == 'v1':
		world_center = world_size / 2
		world_radius = world_size / 4
		falloff_power = 0.5
		
		noise = FastNoiseLite.new()
		
		noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
		if random_seed == false:
			noise.seed = world_seed
		else:
			noise.seed = randi_range(1, 99999999)
		noise.frequency = 0.0038
		noise.fractal_type = FastNoiseLite.FRACTAL_FBM
		noise.fractal_octaves = 5 
		noise.fractal_gain = 0.5
		noise.fractal_weighted_strength = 0
	world_generation(noise, world_center, falloff_power)

func world_generation(noise, world_center, falloff_power:= 0.0):
	var source_id = 0
	var land_coord = Vector2(0, 0)
	var sand_coord = Vector2(1, 0)
	var shore_coord = Vector2(2, 0)
	var sea_coord = Vector2(3, 0)
	
	temp_array = []
	for x in range(world_size):
		for y in range(world_size):
			var distance = sqrt((x - world_center) * (x - world_center) + (y - world_center) * (y - world_center))
			var noise_values = noise.get_noise_2d(x * 2, y * 2)
			var noise_value = noise_values + (falloff_power * smoothstep(world_size / 4, world_size / 2, distance))
			
			if noise_value < -0.35:
				ground.set_cell(Vector2(x, y), source_id, land_coord) # land
				if noise_value < -0.375:
					temp_array.append(Vector2(x, y))
			elif noise_value > -0.35:
				ground.set_cell(Vector2(x, y), source_id, sand_coord) # sand
				#sand_array.append(Vector2(x, y))
				if noise_value > -0.225:
					ground.set_cell(Vector2(x, y), source_id, shore_coord) # shore
				if noise_value > -0.1:
					ground.set_cell(Vector2(x, y), source_id, sea_coord) # sea
					#land_array.append(Vector2(x, y))

func environment_generation():
	environment.clear()
	#for j in environment.get_used_cells():
	#	environment.set_cell(j, 0, Vector2i(-1, -1))
	var randumb: int
	for i in temp_array:
		randumb = randi_range(1, 80)
		if randumb > 75:
			environment.set_cell(i, 0, Vector2i(0, 0))

func generation(random_seed:= true):
	noise_generation(random_seed)
	environment_generation()

func _ready() -> void:
	generation()

func _process(delta: float) -> void:
	if Input.is_action_pressed("debug_1"):
		$Camera2D.position = get_global_mouse_position()
	if Input.is_action_pressed("key_down"):
		$Camera2D.zoom += Vector2(0.01, 0.01)
	elif Input.is_action_pressed("key_up"):
		$Camera2D.zoom -= Vector2(0.01, 0.01)
	
	if Input.is_action_just_pressed("debug_2"):
		print("HEYYYY")
		$CanvasLayer/RichTextLabel.text = "[b]generating...\nplease wait"
		await get_tree().create_timer(2).timeout
		generation(true)
		$CanvasLayer/RichTextLabel.text = ""
	if Input.is_action_just_pressed("esc"):
		get_tree().quit()
