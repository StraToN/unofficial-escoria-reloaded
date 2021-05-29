# `repeat`
#
# Restarts the execution of the current scope at the start. A scope can be a 
# group or an event.
# 
# @ESC
extends ESCBaseCommand
class_name RepeatCommand


# Return the descriptor of the arguments of this command
func configure() -> ESCCommandArgumentDescriptor:
	return ESCCommandArgumentDescriptor.new(
		0, 
		[],
		[]
	)


# Run the command
func run(current_context: Dictionary, command_params: Array) -> int:
	return ESCEventManager.RC_CANCEL
