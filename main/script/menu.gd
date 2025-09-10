extends Control

@onready var experimental := false

func _ready() -> void:
	experimental = true
	if experimental == true:
		pass#$experimental_anim_play.play("bg")
	if $sub_setting_gfx/gfx/animated_bg_menu.is_pressed() == true:
		$experimental_anim_play.play("bg")
	else:
		$experimental_anim_play.stop()

func _button(trigger, back, animation):
	pass



func _menu_anim() -> void:
	if $main_btn/exit.button_pressed:
		get_tree().quit()
	
	if $main_btn/play.button_pressed:
		$ui_anim_play.play("anim_play")
	elif $play_btn/back.button_pressed:
		$ui_anim_play.play("anim_play", -1, -2, true)
		
	if $main_btn/setting.button_pressed:
		$ui_anim_play.play("anim_setting")
	elif $setting_btn/back.button_pressed:
		$ui_anim_play.play("anim_setting", -1, -2, true)
		
	if $setting_btn/gfx.button_pressed:
		$ui_anim_play.play("anim_setting_gfx")
	elif $sub_setting_gfx/back.button_pressed:
		$ui_anim_play.play("anim_setting_gfx", -1, -2, true)
		
	if $setting_btn/control.button_pressed:
		$ui_anim_play.play("anim_setting_control")
	elif $sub_setting_control/back.button_pressed:
		$ui_anim_play.play("anim_setting_control", -1, -2, true)
		
	if $setting_btn/about.button_pressed:
		$ui_anim_play.play("anim_setting_about")
	elif $sub_setting_about/back.button_pressed:
		$ui_anim_play.play("anim_setting_about", -1, -2, true)
		
	if $setting_btn/storage.button_pressed:
		$ui_anim_play.play("anim_setting_storage")
	elif $sub_setting_storage/back.button_pressed:
		$ui_anim_play.play("anim_setting_storage", -1, -2, true)
	
	if $play_btn/single.button_pressed:
		$ui_anim_play.play("anim_play_single_or_host")
		$sub_play_single_or_host/split/label.text = "[center][b][wave]singleplayer"
		$sub_play_single_or_host/split/sub_label.text = "[center]create or choose an existing world"
	elif $play_btn/multi/host.button_pressed:
		$ui_anim_play.play("anim_play_single_or_host")
		$sub_play_single_or_host/split/label.text = "[center][b][wave]multiplayer"
		$sub_play_single_or_host/split/sub_label.text = "[center]create or choose an existing world to host"
	elif $sub_play_single_or_host/split/back.button_pressed:
		$ui_anim_play.play("anim_play_single_or_host", -1, -2, true)
	
	if $play_btn/multi/join.button_pressed:
		$ui_anim_play.play("anim_play_multi_join")
	elif $sub_play_multi_join/split/back.button_pressed:
		$ui_anim_play.play("anim_play_multi_join", -1, -2, true)

func _process(delta: float) -> void:
	_menu_anim()
	
	
	
	#about
	##apps
	if $sub_setting_about/apps/fb.button_pressed:
		OS.shell_open("https://www.facebook.com/abde4a")
	elif $sub_setting_about/apps/x.button_pressed:
		OS.shell_open("https://x.com/_abde4803")
	elif $sub_setting_about/apps/itch.button_pressed:
		OS.shell_open("https://ashari-cat.itch.io")


func _on_animated_bg_menu_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$experimental_anim_play.play("bg")
	else:
		$experimental_anim_play.stop()
