# `stop`
#
# Stops the event's execution.
# 
# @ESC
extends ESCBaseCommand
class_name StopCommand


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
