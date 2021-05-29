# `wait seconds`
#
# Blocks execution of the current script for a number of seconds specified by the "seconds" parameter.
#
# @ESC
extends ESCBaseCommand
class_name WaitCommand


# Return the descriptor of the arguments of this command
func configure() -> ESCCommandArgumentDescriptor:
	return ESCCommandArgumentDescriptor.new(
		1, 
		[TYPE_INT],
		[null]
	)


# Run the command
func run(current_context: Dictionary, command_params: Array) -> int:
	yield(get_tree().create_timer(command_params[0]), "timeout")
	return ESCEventManager.RC_OK
