# `set_state object state`
#
# Changes the state of an object, and executes the state animation if present. 
# The command can be used to change the appearance of an item or a player 
# character.
#
# @ESC
extends ESCBaseCommand
class_name SetStateCommand


# Return the descriptor of the arguments of this command
func configure() -> ESCCommandArgumentDescriptor:
	return ESCCommandArgumentDescriptor.new(
		2, 
		[TYPE_STRING, TYPE_STRING],
		[null, null]
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
	(escoria.object_manager.objects[command_params[0]] as ESCObject).state = \
			command_params[1]
	return ESCExecution.RC_OK
