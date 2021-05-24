# The descriptor of the arguments of an ESC command
extends Object
class_name ESCCommandArgumentDescriptor


# Number of arguments the command expects
var min_args: int = 0

# The types the arguments as TYPE_ constants
var types: Array = []


# Initialize the descriptor
func _init(p_min_args: int = 0, p_types: Array = []):
	min_args = p_min_args
	types = p_types


# Validate wether the given arguments match the command descriptor
func validate(command: String, arguments: Array) -> bool:
	if arguments.size() < self.min_args:
		escoria.logger.report_errors(
			"Invalid command arguments for command %s" % command,
			[
				"Arguments didn't match minimum size %d: %s" %
					self.min_args,
					arguments
			]
		)
	
	for index in range(arguments.size()):
		if typeof(arguments[index]) != self.types[index]:
			escoria.logger.report_errors(
				"Argument type did not match descriptor for command %s" % command,
				[
					"Argument %d is of type %d. Expected %d" % [
						index,
						typeof(arguments[index]),
						self.types[index]
					]
				]
			)
	
	return true
