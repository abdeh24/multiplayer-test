extends CanvasLayer

var next_scene = "res://scenes/world.tscn"
var processed = ["Generating Terrains", "Growing Trees", "Creating Caves Structures", "Generating Biomes", "Some \"Plants\" For The Finishing"]

var passedforthis = true
var passedfor = true
var passed = false

func _ready() -> void:
	ResourceLoader.load_threaded_request(next_scene)

func _process(delta: float) -> void:
	var progress = []
	ResourceLoader.load_threaded_get_status(next_scene, progress)
	$vContainer/progress.value = progress[0]*100
	$vContainer/percentage.text = "LOADING... "+str(floor(progress[0]*100))+"%"
	if progress[0]*100 <= 20:
		$vContainer/processed.text = processed[0]
	elif progress[0]*100 <= 40:
		$vContainer/processed.text = processed[1]
	elif progress[0]*100 <= 60:
		$vContainer/processed.text = processed[2]
		print(progress[0]*100)
	elif progress[0]*100 <= 80:
		$vContainer/processed.text = processed[3]
	elif progress[0]*100 <= 100:
		$vContainer/processed.text = processed[4]
	
	if $vContainer/progress.value == 100:
		if passedfor == true:
			passedfor = false
			passed = true
			go_to_loaded_scene($vContainer/progress.value)
			print("how much this instances running?")
	
	
	
func go_to_loaded_scene(value):
	if passed == true:
		passedfor == false
		
	if passedforthis == true:
		if passedfor == false:
			passedforthis = false
			if value == 100:
				print(value)
				get_tree().create_timer(1)
				print(value)
				var packed_scene = ResourceLoader.load_threaded_get(next_scene)
				get_tree().change_scene_to_packed(packed_scene)
