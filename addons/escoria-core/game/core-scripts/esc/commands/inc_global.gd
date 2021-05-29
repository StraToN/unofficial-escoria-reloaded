# `inc_global name value`
#
# Adds the value to global with given "name". Value and global must both be 
# integers.
#
# @ESC
extends ESCBaseCommand
class_name IncGlobalCommand


# Return the descriptor of the arguments of this command
func configure() -> ESCCommandArgumentDescriptor:
	return ESCCommandArgumentDescriptor.new(
		2, 
		[TYPE_STRING, TYPE_INT],
		[null, 0]
	)


# Validate wether the given arguments match the command descriptor
func validate(arguments: Array):
	if not escoria.globals.globals[arguments[0]] is int:
		escoria.logger.report_errors(
			"inc_global: invalid global",
			[
				"Global %s didn't have an integer value." % arguments[0]
			]
		)
		return false
	return .validate(arguments)


# Run the command
func run(current_context: Dictionary, command_params: Array) -> int:
	escoria.globals.globals[command_params[0]] += command_params[1]
	return ESCEventManager.RC_OK
