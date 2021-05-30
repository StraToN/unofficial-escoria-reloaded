extends Control


func _ready():
	var rc = escoria.command_registry.get_command("set_sound_state").run(
		[
			"bg_music", 
			"res://game/sfx/Game-Menu_Looping.mp3",
			true
		]
	)
	
	if rc != ESCExecution.RC_OK:
		escoria.logger.report_errors(
			"main_menu: Can't start menu music",
			[
				"set_sound_state returned %d" % rc
			]
		)
		return false


func _on_continue_pressed():
	pass





func switch_language(lang : String):
	TranslationServer.set_locale(lang)


func _on_new_game_pressed():
	escoria.new_game()

func _on_load_game_pressed():
	#  Show Loading screen
	pass

func _on_options_pressed():
	$Panel/main.hide()
	$Panel/options.show()

func _on_quit_pressed():
	get_tree().quit()

###########################################################################
###########################################################################
# OPTIONS


func _on_back_pressed():
	$Panel/options.hide()
	$Panel/main.show()
	
