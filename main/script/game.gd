extends Node2D

@onready var world_seed:= 4803
@onready var world_size:= 512
@onready var world_gen:= 'v1'

@onready var ground = $ground
@onready var environment = $environment

@onready var peer = ENetMultiplayerPeer

@export var player_base:= PackedScene
@export var noise_height_text: NoiseTexture2D
@export var noise_env_text: NoiseTexture2D

@onready var temp_array: Array

func noise_generation(random_seed:= false):
	var world_center
	var world_radius
	var falloff_power
	var noise
	var env_noise
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
		
		# ENV NOISE
		env_noise = FastNoiseLite.new()
		
		env_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
		if random_seed == false:
			env_noise.seed = world_seed
		else:
			env_noise.seed = randi_range(1, 99999999)
		env_noise.frequency = 0.25
		env_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
		env_noise.fractal_octaves = 1
		
		
		
	world_generation(noise, env_noise, world_center, falloff_power)

func world_generation(noise, env_noise, world_center, falloff_power:= 0.0):
	$environment.clear()
	var source_id = 0
	var land_coord = Vector2(0, 0)
	var sand_coord = Vector2(1, 0)
	var shore_coord = Vector2(2, 0)
	var sea_coord = Vector2(3, 0)
	
	var tree_variant = [Vector2(6, 0), Vector2(4, 0), Vector2(6, 5), Vector2(1, 3)]
	var bush_variant = [Vector2(0, 0), Vector2(0, 2), Vector2(2, 2), Vector2(0, 3)]
	var rock_variant = [Vector2(2, 0), Vector2(1, 2)]
	
	temp_array = []
	for x in range(world_size):
		for y in range(world_size):
			var distance = sqrt((x - world_center) * (x - world_center) + (y - world_center) * (y - world_center))
			var noise_values = noise.get_noise_2d(x * 2, y * 2)
			var noise_value = noise_values + (falloff_power * smoothstep(world_size / 4, world_size / 2, distance))
			
			var env_noise_values = env_noise.get_noise_2d(x * 2, y * 2)
			var env_noise_value = env_noise_values + + (falloff_power * smoothstep(world_size / 4, world_size / 2, distance))
			temp_array.append(env_noise_value)
			if noise_value < -0.36 and env_noise_value < -0.5:
				environment.set_cell(Vector2(x, y), source_id, bush_variant.pick_random())
			if noise_value < -0.3505 and env_noise_value < -0.7:
				environment.set_cell(Vector2(x, y), source_id, tree_variant.pick_random())
			elif noise_value < -0.105 and env_noise_value > 0.9:
				environment.set_cell(Vector2(x, y), source_id, rock_variant.pick_random())
				
			
			if noise_value < -0.35:
				ground.set_cell(Vector2(x, y), source_id, land_coord) # land
			elif noise_value > -0.35:
				ground.set_cell(Vector2(x, y), source_id, sand_coord) # sand
				#sand_array.append(Vector2(x, y))
				if noise_value > -0.225:
					ground.set_cell(Vector2(x, y), source_id, shore_coord) # shore
				if noise_value > -0.1:
					ground.set_cell(Vector2(x, y), source_id, sea_coord) # sea
					#land_array.append(Vector2(x, y))
	print("max: ", temp_array.max())
	print("min: ", temp_array.min())

func generation(random_seed:= true):
	noise_generation(random_seed)

func _ready() -> void:
	generation(false)

func _process(delta: float) -> void:
	if Input.is_action_pressed("debug_1"):
		$Camera2D.position = get_global_mouse_position()
	if Input.is_action_pressed("key_down"):
		$Camera2D.zoom += Vector2(0.01, 0.01)
	elif Input.is_action_pressed("key_up"):
		$Camera2D.zoom -= Vector2(0.01, 0.01)
	$render_distance.position = get_global_mouse_position()
	if Input.is_action_just_pressed("debug_2"):
		print("HEYYYY")
		$CanvasLayer/RichTextLabel.text = "[b]generating...\nplease wait"
		await get_tree().create_timer(2).timeout
		generation(true)
		$CanvasLayer/RichTextLabel.text = ""
	if Input.is_action_just_pressed("esc"):
		get_tree().quit()
