# change_scene path run_events
# Loads a new scene, specified by "path". The `run_events` variable is a 
# boolean (default true) which you never want to set manually! It's there only 
# to benefit save games, so they don't conflict with the scene's events.
# @ESC
extends ESCBaseCommand
class_name ChangeSceneCommand


# Return the descriptor of the arguments of this command
func configure() -> ESCCommandArgumentDescriptor:
	return ESCCommandArgumentDescriptor.new(1, [TYPE_STRING, TYPE_BOOL])


# Run the command
func run(current_context: Dictionary, command_params: Array) -> int:
	# Savegames must have events disabled, so saving the game adds a false to params
	var run_events = true
	if command_params.size() == 2:
		run_events = bool(command_params[1])
	
	# looking for localized string format in scene. this should be somewhere else
	var sep = command_params[0].find(":\"")
	if sep >= 0:
		var path = command_params[0].substr(sep + 2, command_params[0].length() - (sep + 2))
		escoria.esc_runner.call_deferred("change_scene", [path], current_context, run_events)
	else:
		escoria.esc_runner.call_deferred("change_scene", command_params, current_context, run_events)
	
	current_context.waiting = true
	return esctypes.EVENT_LEVEL_STATE.YIELD
