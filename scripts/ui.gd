extends CanvasLayer

@onready var g = get_node("/root/Global")

func _process(delta: float) -> void:
	g = get_node("/root/Global")
	if g.debug >= 1:
		$Control/debug.visible = true
		var position_fixed = (str(round(g.position.x / 16)) + ", " + str(round(g.position.y / 16)))
		$Control/debug/position.text = "Position : " + position_fixed
	else:
		$Control/debug.visible = false
