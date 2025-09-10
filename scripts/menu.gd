extends Control

@onready var mainButton = [$mainUI/mainButton/hostWorld, $mainUI/mainButton/joinWorld]
@onready var hostInput = [$mainUI/hostWorld/LineEdit, $mainUI/hostWorld/LineEdit2]
@onready var back = [$mainUI/hostWorld/back, $mainUI/joinWorld/back, $mainUI/createWorld/back]
@onready var joinInput = [$mainUI/joinWorld/LineEdit, $mainUI/joinWorld/LineEdit2]
@onready var g = get_node("/root/Global")
@onready var user_path = g.user_path
@onready var data_path = user_path + "/player/data.json"
@onready var player_data = {}
var multi = false
var host = 0 #0 not hosting, 1 hosting, 2 join
var mode = [] #single, multi, host, join, create, load

var ip = "127.0.0.1"
var port = 8080

var world = 0 #1 new, 2 load, -1 erase
var num = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]


func _ready() -> void:
	player_filedata("check", {})
	
func player_filedata(whattodo, data):
	var data_exist = true
	if whattodo == "check":
		if DirAccess.dir_exists_absolute(user_path + "/player"):
			if FileAccess.file_exists(data_path):
				data_exist = true
				player_data = JSON.parse_string(FileAccess.open(data_path, FileAccess.READ).get_as_text())
			else:
				data_exist = false
				print("dir exist, but no data")
				print(user_path + "/player")
		else:
			DirAccess.make_dir_absolute(user_path + "/player")
			data_exist = false
			print("dir not exist and no data")
	if data_exist == false:
		print("data creating")
		var default_data = {
			"name": "null",
			"appearance" : {
				"skin_color": "#ffffff",
				"head": {
					"hair_type": 0,
					"color": "#ffffff"
				},
				"body": {
					"shirt_type": 0,
					"color": "#ffffff"
				},
				"leg" : {
					"trousers_type": 0,
					"color": "#ffffff"
				}
			}
		}
		data = default_data
	if whattodo == "save" or data_exist == false:
		var file = FileAccess.open(data_path, FileAccess.WRITE)
		var json = JSON.stringify(data, "\t")
		file.store_string(json)
		file.close()
		data_exist = true
		

func old() -> void:
	g = get_node("/root/Global")
	if mainButton[0].is_pressed():
		$mainUI/mainButton.visible = false
		$mainUI/hostWorld.visible = true
	elif mainButton[1].is_pressed():
		$mainUI/mainButton.visible = false
		$mainUI/joinWorld.visible = true
	elif $mainUI/hostWorld/create.is_pressed():
		$mainUI/joinWorld.visible = false
		$mainUI/hostWorld.visible = false
		$mainUI/mainButton.visible = false
		$mainUI/createWorld.visible = true
	elif back[0].is_pressed() or back[1].is_pressed() or back[2].is_pressed():
		$mainUI/createWorld.visible = false
		$mainUI/joinWorld.visible = false
		$mainUI/hostWorld.visible = false
		$mainUI/mainButton.visible = true
		
	if $mainUI/mainButton/nameTag.text == "" or null:
		if g.player_name == "":
			g.player_name = g.player_default_name()
			$mainUI/mainButton/nameTag.placeholder_text = g.player_name
	else:
		g.player_name = $mainUI/mainButton/nameTag.text


func button():
	g = get_node("/root/Global")
	#mode
	if $main_ui/mode/single.is_pressed():
		$main_ui/world.visible = true
		$main_ui/mode.visible = false
		multi = false
		host = 0
	elif $main_ui/mode/multi.is_pressed():
		$main_ui/multi.visible = true
		$main_ui/mode.visible = false
		multi = true
	elif $main_ui/mode/tiny_button/char.is_pressed():
		$main_ui/char.visible = true
		$main_ui/mode.visible = false
	
	
	#multi
	if $main_ui/multi/host.is_pressed():
		$main_ui/world.visible = true
		$main_ui/multi.visible = false
		host = 1
	elif $main_ui/multi/join.is_pressed():
		$main_ui/join_world.visible = true
		$main_ui/multi.visible = false
		host = 2
	elif $main_ui/multi/back.is_pressed():
		$main_ui/mode.visible = true
		$main_ui/multi.visible = false
	
	#world
	if $main_ui/world/act/back.is_pressed():
		$main_ui/mode.visible = true
		$main_ui/world.visible = false
	elif $main_ui/world/act/new.is_pressed():
		world = 1
		$main_ui/world.visible = false
		$main_ui/new_world.visible = true
	elif $main_ui/world/act/erase.is_pressed():
		world = -1
	elif $main_ui/world/act/load.is_pressed():
		world = 2
		if multi:
			mode = ["multi", "load", "host"]
		else:
			mode = ["single", "load"]
	
	#join_world
	if $main_ui/join_world/act/back.is_pressed():
		$main_ui/mode.visible = true
		$main_ui/join_world.visible = false
	if $main_ui/join_world/act/join.is_pressed():
		if $main_ui/join_world/address/ip.text != "":
			ip = $main_ui/join_world/address/ip.text
		else:
			ip = "127.0.0.1"
		port = $main_ui/join_world/address/port.value
		mode = ["join"]
		print(ip,":",port)
		
	
	##new world
	if $main_ui/new_world/act/back.is_pressed():
		$main_ui/new_world.visible = false
		$main_ui/world.visible = true
	for i in $main_ui/new_world/seed.text:
		if i not in num:
			$main_ui/new_world/seed.text = $main_ui/new_world/seed.text.replace(i, "")
			$main_ui/new_world/seed.caret_column = len($main_ui/new_world/seed.text)
	if $main_ui/new_world/act/create.is_pressed():
		if multi == false:
			mode = ["single", "create"]
		elif multi == true:
			mode = ["multi", "create", "host"]
	
	
	#char
	if $main_ui/char/navigation/back.is_pressed():
		$main_ui/char.visible = false
		$main_ui/mode.visible = true
	if $main_ui/char/navigation/info.is_pressed():
		$main_ui/char/appearance.visible = true
		$main_ui/char/color.visible = false
	else:
		$main_ui/char/color.visible = true
		$main_ui/char/appearance.visible = false
	if $main_ui/char/appearance/name/input.text == "":
		if g.player_name == null:
			if player_data.name == null:
				g.player_name = g.player_default_name()
				$main_ui/char/appearance/name/input.placeholder_text = g.player_name
			else:
				$main_ui/char/appearance/name/input.text = player_data.name
		else:
			g.player_name = $main_ui/char/appearance/name/input.placeholder_text
	else:
		g.player_name = $main_ui/char/appearance/name/input.text
	
	if $main_ui/char/navigation/done.is_pressed():
		player_data.name = g.player_name
		print(player_data.name)
		player_filedata("save", player_data)
	
func enter_world():
	if "load" in mode or "create" in mode:
		if "host" in mode:
			print("host")
		elif "single":
			print("single")
		if "create" in mode:
			print("mode")
			g.world_name = $main_ui/new_world/name.text
			g.world_seed = $main_ui/new_world/seed.text
			g.world_size = 256 * $main_ui/new_world/size/size.get_selected_id()
			g.host = true
			get_tree().change_scene_to_file("res://scenes/loading.tscn")
	elif "join" in mode:
		g.join = true
		g.ip = ip
		g.port = port
		get_tree().change_scene_to_file("res://scenes/world.tscn")

func _process(delta: float) -> void:
	button()
	print(mode)
	enter_world()
	


##			g.world_name = $main_ui/new_world/name.text
##			g.world_seed = $main_ui/new_world/seed.text
##			g.world_size = 256 * $main_ui/new_world/size/size.get_selected_id()
##			g.host = true
##			get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_host_pressed() -> void:
	g.host = true
	get_tree().change_scene_to_file("res://scenes/loading.tscn")

func _on_join_pressed() -> void:
	g.join = true
	g.ip = joinInput[0].text
	get_tree().change_scene_to_file("res://scenes/world.tscn")
