extends Node2D

func _process(delta: float) -> void:
	$AnimationPlayer.play("blink")
	if Input.is_action_just_pressed("a") or Input.is_action_just_pressed("d"):
		$foot.frame = 2
		$body.frame = 2
		$head.frame = 2
		$eye.visible = false
		$hair.frame = 2
		self.scale.x = Input.get_axis("d", "a")
		
	if Input.is_action_just_pressed("w"):
		$foot.frame = 1
		$body.frame = 1
		$head.frame = 1
		$eye.visible = false
		$hair.frame = 1
	elif Input.is_action_just_pressed("s"):
		$foot.frame = 0
		$body.frame = 0
		$head.frame = 0
		$eye.visible = true
		$hair.frame = 0
		self.scale.x = 1
