# `set_globals pattern value`
#
# Changes the value of multiple globals using a wildcard pattern, where "*" 
# matches zero or more arbitrary characters and "?" matches any single 
# character except a period (".").
#
# @ESC
extends ESCBaseCommand
class_name SetGlobalsCommand


# Return the descriptor of the arguments of this command
func configure() -> ESCCommandArgumentDescriptor:
	return ESCCommandArgumentDescriptor.new(
		2, 
		[TYPE_STRING, TYPE_STRING],
		[null, null]
	)


# Run the command
func run(current_context: Dictionary, command_params: Array) -> int:
	for global_key in escoria.globals.globals.keys:
		if global_key.match(command_params[0]):
			escoria.globals.globals[global_key] = command_params[1]
	return ESCEventManager.RC_OK
