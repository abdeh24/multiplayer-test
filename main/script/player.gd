extends CharacterBody2D

const SPEED = 300.0

func _physics_process(delta: float) -> void:
	var direction := Vector2(Input.get_axis("a", "d"), Input.get_axis("w", "s"))
	if direction.x:
		velocity.x = direction.x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if direction.y:
		velocity.y = direction.y * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()
