extends Container

@export var MAX_X = 0
@export var MIN_X = -64
@export var MAX_Y = 0
@export var MIN_Y = -64

@onready var g = get_node("/root/Global")
@onready var post = Vector2(0, 0)
@onready var joystick_used : bool
@onready var zoom : Vector2 = Vector2(1, 1)
func _process(delta: float) -> void:
	g = get_node("/root/Global")
	joystick_used = g.on_mobile
	if joystick_used:
		if $stick/head.is_pressed():
			$stick/head.position = get_local_mouse_position() - Vector2(64, 64)
			if $stick/head.position.x > MAX_X:
				$stick/head.position.x = MAX_X
			if $stick/head.position.x < MIN_X:
				$stick/head.position.x = MIN_X
			if $stick/head.position.y > MAX_Y:
				$stick/head.position.y = MAX_Y
			if $stick/head.position.y < MIN_Y:
				$stick/head.position.y = MIN_Y
		else:
			$stick/head.position = Vector2(-32, -32)
		
		var pos = $stick/head.position
		if pos.x != -32:
			if pos.x > -32:
				post.x = (pos.x + 64) / 96
			elif pos.x < -32:
				post.x = pos.x / 96
			
		if pos.y != -32:
			if pos.y > -32:
				post.y = (pos.y + 64) / 96
			elif pos.y < -32:
				post.y = pos.y / 96
		else:
			post = Vector2(0, 0)
	else:
		if Input.is_action_pressed("key_up"):
			post.y = -1
		if Input.is_action_pressed("key_down"):
			post.y = 1
		if Input.is_action_pressed("key_left"):
			post.x = -1
		if Input.is_action_pressed("key_right"):
			post.x = 1
		
	if zoom.x >= 0.5:
		if $zoom/out.is_pressed() or Input.is_action_just_pressed("zoom_out"):
			zoom -= Vector2(0.1, 0.1)
	if zoom.x <= 2:
		if $zoom/in.is_pressed() or Input.is_action_just_pressed("zoom_in"):
			zoom += Vector2(0.1, 0.1)
	
	if $stick/exit.is_pressed():
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
	
	g.zoom = zoom
	#print(zoom)
	g.movement_offset = post
	
