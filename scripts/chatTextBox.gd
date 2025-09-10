extends RichTextLabel

@onready var g = get_node("/root/Global")

func _process(delta: float) -> void:
	g = get_node("/root/Global")
	if $input.text != "":
		if $input/send.is_pressed() or Input.is_action_just_pressed("enter"):
			g.msg = $input.text
			g.rpc_used = true
			#self.add_text($input.text + "\n")
			$input.clear()
			
	if g.msg_returned != "":
		self.add_text(g.msg_returned + "\n")
		print(g.msg_returned)
		g.msg_returned = ""


func _on_toggle_chat_toggled(value: bool) -> void:
	if value == true:
		self.size.y = 224
		$toggle_chat.text = "COLLAPSE"
		$toggle_chat.position.y = 232
	else:
		self.size.y = 24
		$toggle_chat.text = "EXPAND"
		$toggle_chat.position.y = 32
