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
		[TYPE_STRING, [TYPE_BOOL, TYPE_STRING, TYPE_INT]],
		[null, null]
	)


# Run the command
func run(command_params: Array) -> int:
	escoria.globals_manager.set_global_wildcard(
		command_params[0],
		command_params[1]
	)
	return ESCExecution.RC_OK
