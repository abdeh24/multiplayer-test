extends CharacterBody2D

@onready var g = get_node("/root/Global")
@onready var first = true
const SPEED = 200.0

var x_or_y = 0
var temp = false
var facing = Vector2()

func _ready() -> void:
	if is_multiplayer_authority():
		$nameTag.text = g.player_name

#REMOVE @rpc("any_peer")
#REMOVE func set_name_tag(name: String) -> void:
#REMOVE 	$nameTag.text = name

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _process(delta: float) -> void:
	g = get_node("/root/Global")
	if first == true:
		first = false
		if $nameTag.text != "ERR/IOV":
			g.msg = "<System> "+$nameTag.text+" Joined!"
			g.rpc_used = true
	
	$camera.zoom = g.zoom
	
	if is_multiplayer_authority():
		$camera.make_current()
		g.position = Vector2(self.global_position.x, self.global_position.y)
		var direction = g.movement_offset
		#velocity.x = SPEED * direction.x
		#velocity.y = SPEED * direction.y
		
		if direction != Vector2(0, 0):
			if direction.x >= 0.1:
				facing.x = -1
			else:
				facing.x = 1
			
			if direction.y >= 0.1:
				facing.y = -1
			else:
				facing.y = 1
				
			if facing.x != 0:
				if direction.y <= 0.4 or direction.y >= -0.4:
					$texture2/baseLeg.frame = 2
					$texture2/baseBody.frame = 2
					$texture2/baseHead.frame = 2
					$texture2.scale.x = facing.y * 3
			if direction.x >= 0.5 or direction.x <= -0.5:
				if facing.y == 1:
					$texture2/baseLeg.frame = 1
					$texture2/baseBody.frame = 1
					$texture2/baseHead.frame = 1
				else:
					$texture2/baseLeg.frame = 0
					$texture2/baseBody.frame = 0
					$texture2/baseHead.frame = 0
		else:
			pass
			#facing = Vector2(0, 0)
		
		
		
		
			
	if g.join == true:
		if g.server_info != {}:
			print(g.server_info)
			self.position = g.server_info.spawn_point
	
	move_and_slide()
