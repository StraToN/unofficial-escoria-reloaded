# `set_state object state [immediate]`
#
# Changes the state of an object, and executes the state animation if present. 
# The command can be used to change the appearance of an item or a player 
# character.
# If `immediate` is set to true, the animation is run directly
#
# @ESC
extends ESCBaseCommand
class_name SetStateCommand


# Return the descriptor of the arguments of this command
func configure() -> ESCCommandArgumentDescriptor:
	return ESCCommandArgumentDescriptor.new(
		2, 
		[TYPE_STRING, TYPE_STRING, TYPE_BOOL],
		[null, null, false]
	)
	

# Validate wether the given arguments match the command descriptor
func validate(arguments: Array):
	if not escoria.object_manager.objects.has(arguments[0]):
		escoria.logger.report_errors(
			"set_state: invalid object",
			[
				"Object %s not found." % arguments[0]
			]
		)
		return false
	return .validate(arguments)


# Run the command
func run(command_params: Array) -> int:
	(escoria.object_manager.objects[command_params[0]] as ESCObject).set_state(
		command_params[1],
		command_params[2]
	)
	return ESCExecution.RC_OK
