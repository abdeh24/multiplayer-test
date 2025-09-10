extends Node2D

@onready var g = get_node("/root/Global")
@onready var peer = ENetMultiplayerPeer.new()
@export var playerScene: PackedScene

var port = 8080

@onready var ground = $ground
@export var noise_height_text:  NoiseTexture2D
var noise: Noise

var source_id = 0
var land_coord = Vector2(0, 0)
var sand_coord = Vector2(1, 0)
var shore_coord = Vector2(2, 0)
var sea_coord = Vector2(3, 0)

var land_array = []
var sand_array = []

var world_name = "New World"
var world_size = 128
var world_seed = 0

var noise_value_array: Array
var info : Dictionary = {}
var generated : bool = false

var designated_spawn_point : Vector2
var just_joined : bool
var player_joined : CharacterBody2D

func _ready() -> void:
	if g.host == true:
		world_name = g.world_name
		world_size = int(g.world_size)
		world_seed = int(g.world_seed)
		generate_world(world_seed)
	else:
		if info != {}:
			world_name = info.name
			world_seed = info.seed
			world_size = info.size
			generate_world(world_seed)
			designated_spawn_point = info.spawn_point
	#print(info)

func generate_world(seed: int):
	var island_center = world_size / 2
	var island_radius = world_size / 4
	var falloff_power = 0.5
	
	noise = FastNoiseLite.new()
	
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.seed = seed
	noise.frequency = 0.0038
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 5 
	noise.fractal_gain = 0.5
	noise.fractal_weighted_strength = 0
	
	for x in range(world_size):
		for y in range(world_size):
			var distance = sqrt((x - island_center) * (x - island_center) + (y - island_center) * (y - island_center))
			var noise_values = noise.get_noise_2d(x * 2, y * 2)
			var noise_value = noise_values + (falloff_power * smoothstep(world_size / 4, world_size / 2, distance))
			
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
					
	
	generated = true

func finishing_world():
	pass
	#sand_ground.set_cells_terrain_connect(sand_array, 0, 1, false)
	#grass_ground.set_cells_terrain_connect(land_array, 0, 0, false)

func save_world():
	g = get_node("/root/Global")
	var data = {"world_name": "New_World", "world_size": 256, "world_seed": 4803, "world_tile_data": [], "world_spawn_point": Vector2()}
	var tile_data: Array
	for x in range(world_size):
		for y in range(world_size):
			tile_data.append(ground.get_cell_atlas_coords(Vector2i(x, y)))
			
	data.world_name = world_name
	data.world_size = world_size
	data.world_seed = world_seed
	data.world_tile_data = tile_data
	data.world_spawn_point = designated_spawn_point
	
	var save_prefix = world_name + ".savd"
	g.check_dir("/saves")
	g.check_dir("/saves/worlds")
	g.save_game("/saves/worlds/" + save_prefix, "world", data)

func _process(delta: float) -> void:
	g = get_node("/root/Global")
	if g.host == true:
		peer.create_server(port)
		multiplayer.multiplayer_peer = peer
		multiplayer.peer_connected.connect(_add_player)
		_add_player()
		post_message("<System> World hosted at: " + str(what_ip_am_i_host_in(port)))
		g.host = false
	elif g.join == true:
		peer.create_client(g.ip, port)
		print("<System> Connecting to: ", g.ip + ":" +str(port))
		multiplayer.multiplayer_peer = peer
		#_add_player()
		#_position_player()
		##TEMPprint(info)
		just_joined = true
		print(just_joined)
		g.join = false
		
	#22HEHE if just_joined == true:
	#22HEHE 	var player_in_server : Array
	#22HEHE 	var children = self.get_children()
	#22HEHE 	var i = 0
	#22HEHE 	for players in children:
	#22HEHE 		if players is CharacterBody2D:
	#22HEHE 			player_in_server.append(players)
	#22HEHE 			print("SOMETHING WRONG HERE")
	#22HEHE 	print(player_in_server)
	#22HEHE 	#player_joined = player_in_server[len(player_in_server) - 1]
	#22HEHE 	#_position_player(player_joined)
	#22HEHE 	if len(children) != 5:
	#22HEHE 		player_joined = player_in_server[len(player_in_server) - 1]
	#22HEHE 		_position_player(player_joined)
	#22HEHE 		just_joined = false
	#22HEHE 			#print(player_in_server)
		
		#just_joined = false
		
		#print(player_joined)
		#TEMPORARI print(self.get_children())
		#TEMPORARI var children = self.get_children()
		#TEMPORARI player_joined = children[len(children)]
		#TEMPORARI print(player_joined)
		#TEMPORARI _position_player(player_joined)
		#just_joined = false
		
	#multiplayer.peer_connected.connect(_connected)
	#multiplayer.peer_disconnected.connect(_disconnected)
	
	if g.rpc_used == true:
		post_message(g.msg)
		print(g.msg)
		g.rpc_used = false
	
	if Input.is_action_just_pressed("ui_accept"):
		#save_world()
		pass
	
func _spawn_point():
	var index = $ground
	var array_of_position : Array
	for target in index.get_used_cells_by_id(0, Vector2i(0, 0)):
		var target_is_global = index.map_to_local(target) + Vector2((16 / 2), (16 / 2))
		array_of_position.append(target_is_global)
		
	
	var true_target = array_of_position[randi_range(0, len(array_of_position))]
	return true_target


func _add_player(id = 1):
	var player = playerScene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)
	#post_message("<System> "+g.player_name+" Joined!")
	_position_player(player)
	rpc("server_info", info)
	

func _connected(id = 1):
	print("SOMEONE CONNECTED")
	rpc("server_info", info)
func _disconnected(id = 1):
	print("SOMEONE DISCONNECTED")
func _position_player(player):
	if g.host == true:
		designated_spawn_point = _spawn_point()
		update_info()
	player.position = designated_spawn_point
	#Vector2(2896, 3232)

func update_info():
	info = {
		"name": world_name,
		"seed": world_seed,
		"size": world_size,
		"spawn_point": designated_spawn_point
	}
	g.server_info = info

func what_ip_am_i_host_in(port: int) -> String:
	var ip_list = IP.get_local_addresses()
	
	for ip in ip_list:
		if not ip.begins_with("127.") and ip.find(":") == -1:
			return ip + ":" + str(port)
			
	return "127.0.0.1" + ":" + str(port)

func post_message(text: String):
	print(text)
	if text != "":
		if text.begins_with("<System>"):
			rpc("receive_message", text)
			receive_message(text)
		else:
			var msg = "<" + str(g.player_name) + "> " + text
			rpc("receive_message", msg)
			receive_message(msg)

@rpc("any_peer")

func server_info(info : Dictionary):
	print("server info: ", info)
	if generated == false:
		if info != {}:
			update_info()
			world_name = info.name
			world_seed = info.seed
			world_size = info.size
			generate_world(world_seed)
			designated_spawn_point = info.spawn_point
			g.server_info = info

@rpc("any_peer")

func receive_message(message: String):
	g.msg_returned = message

func _procdess(delta: float) -> void:
	g = get_node("/root/Global")
	if g.host == true:
		peer.create_server(port)
		multiplayer.multiplayer_peer = peer
		multiplayer.peer_connected.connect(_add_player)
		_add_player()
		post_message("[SYS] World hosted at: " + str(what_ip_am_i_host_in(port)))
		g.host = false
	elif g.join == true:
		peer.create_client(g.ip, port)
		print("connecting to: ", g.ip + ":" +str(port))
		multiplayer.multiplayer_peer = peer
		g.join = false
		
	
	if g.rpc_used == true:
		post_message(g.msg)
		g.rpc_used = false

func _add_pdlayer(id = 1):
	var player = playerScene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)


func _is_server(type):
	if type == false:
		pass #singleplayer()
	else:
		pass #host()
	
