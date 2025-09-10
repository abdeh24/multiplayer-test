extends Node

var host: bool
var join: bool
var ip: String
var port: int
var msg = ""
var msg_returned = ""
var rpc_used = false
var movement_offset = Vector2(0, 0)
var player_name
var name_tag
var on_mobile : bool = true
var debug : int = 2 #0hide,1user_accessible,2dev
var zoom : Vector2 = Vector2(1, 1)
var server_info : Dictionary = {}

#new world
var world_name : String = "New World"
var world_seed : int = 4803
var world_size : int= 256
var world_spawn_point

#player
var position : Vector2


func player_default_name():
	player_name = "Player" + str(int(randf_range(0, 1) * 100))
	return player_name

func _process(delta: float) -> void:
	#print(movement_offset)
	pass



const DATA_KEY = "AWAWAWAW"
var save_name = "New_World"
var user_path = OS.get_user_data_dir()

func check_dir(path):
	var save_path = user_path + path
	if DirAccess.dir_exists_absolute(save_path):
		print("Dir Verified")
	else:
		DirAccess.make_dir_absolute(save_path)
		print("CREATED")

func save_game(path, data_type, data_input):
	var save_path = user_path + path
	var data: Dictionary
	#var file = FileAccess.open_encrypted_with_pass(save_path, FileAccess.WRITE, DATA_KEY)
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if data_type == "world":
		if file == null:
			print(FileAccess.get_open_error())
			print("error here")
			return
		if data_input == {}:
			data = {
				"world_name": "New_World",
				"world_size": 256,
				"world_seed": 4803,
				"world_tile_data": [],
				"world_spawn_point": Vector2()
			}
			
		else:
			data = data_input
			
	var json = JSON.stringify(data, "\t")
	file.store_string(json)
	file.close()

#DELETEfunc checkDir():
#DELETE	var i = 0
#DELETE	print("START")
#DELETE	
#DELETE	var gamesavePath = userPath + "/game_saves"
#DELETE	
#DELETE	print("Checking \"game_saves\" dir...")
#DELETE	if DirAccess.dir_exists_absolute(gamesavePath):
#DELETE		print("Dir exist!")
#DELETE		while i != 3:
#DELETE			var path = userPath + "/game_saves/savedata" + str(i + 1) + ".islsv"
#DELETE			if !FileAccess.file_exists(path):
#DELETE				saveData(i, {})
#DELETE			i += 1
#DELETE		i = 0
#DELETE	else:
#DELETE		print("Dir doesn't exist, creating & re-run function...")
#DELETE		DirAccess.make_dir_absolute(userPath + "/game_saves")
#DELETE		print("END\n")
#DELETE		checkDir()
#DELETE		return
#DELETE	print("END")
#DELETE
#DELETEfunc saveData(saveId: int, dataSaved: Dictionary):
#DELETE	var data: Dictionary
#DELETE	var path = userPath + "/game_saves/savedata" + str(saveId + 1) + ".islsv"
#DELETE	var file = FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, DATA_KEY)
#DELETE	if file == null:
#DELETE		print(FileAccess.get_open_error())
#DELETE		return
#DELETE	if dataSaved == {}:
#DELETE		data = {
#DELETE			"player":{
#DELETE				"scene": "Empty"
#DELETE			}
#DELETE		}
#DELETE	else:
#DELETE		data = dataSaved
#DELETE		
#DELETE	var json = JSON.stringify(data, "\t")
#DELETE	file.store_string(json)
#DELETE	file.close()
#DELETE
#DELETEfunc loadData(saveId: int):
#DELETE	var path = userPath + "/game_saves/savedata" + str(saveId + 1) + ".islsv"
#DELETE	if FileAccess.file_exists(path):
#DELETE		var file = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, DATA_KEY)
#DELETE		if file == null:
#DELETE			print(FileAccess.get_open_error())
#DELETE			return
#DELETE		
#DELETE		var content = file.get_as_text()
#DELETE		file.close()
#DELETE		var data = JSON.parse_string(content)
#DELETE		if data == null:
#DELETE			printerr("Unable to parse %s as JSON: %s" % [path, content])
#DELETE			saveName = "Empty"
#DELETE			return saveName
#DELETE		else:
#DELETE			saveName = data.player.scene
#DELETE			return saveName
#DELETE	else:
#DELETE		print("Unable to open %s dir" % [path])
#DELETE		saveName = "Corrupted/InvalidPath"
#DELETE		return saveName
#DELETE
