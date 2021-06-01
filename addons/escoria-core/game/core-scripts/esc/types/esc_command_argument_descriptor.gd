# The descriptor of the arguments of an ESC command
extends Object
class_name ESCCommandArgumentDescriptor


# Number of arguments the command expects
var min_args: int = 0

# The types the arguments as TYPE_ constants. If the command is called with
# more arguments than there are entries in the types array, the additional
# arguments will be checked against the last entry of the types array.
var types: Array = []

# The default values for the arguments
var defaults: Array = []


# Initialize the descriptor
func _init(p_min_args: int = 0, p_types: Array = [], p_defaults: Array = []):
	min_args = p_min_args
	types = p_types
	defaults = p_defaults
	

# Combine the default argument values with the given arguments
func prepare_arguments(arguments: Array) -> Array:
	var complete_arguments = defaults
	
	var regex_bool = RegEx.new()
	regex_bool.compile("^true|false$")
	var regex_float = RegEx.new()
	regex_float.compile("^[0-9]+\\.[0-9]+$")
	var regex_int = RegEx.new()
	regex_int.compile("^[0-9]+$")
	
	for index in range(arguments.size()):
		if regex_float.search(arguments[index]):
			complete_arguments[index] = float(arguments[index])
		elif regex_int.search(arguments[index]):
			complete_arguments[index] = int(arguments[index])
		elif regex_bool.search(arguments[index].to_lower()):
			complete_arguments[index] = bool(arguments[index])
		else:
			complete_arguments[index] = str(arguments[index])
		
	return complete_arguments


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
		if arguments[index] == null:
			# No type checking for null values
			continue
		var correct = false
		var types_index = index
		if types_index > types.size():
			types_index = types.size() - 1
		if not self.types[types_index] is Array:
			self.types[types_index] = [self.types[index]]
		for type in self.types[types_index]:
			if not correct:
				correct = self._is_type(arguments[index], type)
			
		if not correct:
			escoria.logger.report_errors(
				"Argument type did not match descriptor for command %s" % 
						command,
				[
					"Argument %d is of type %d. Expected %d" % [
						index,
						typeof(arguments[index]),
						self.types[types_index]
					]
				]
			)
	
	return true


# Check wether the given argument is of the given type
#
# #### Parameters
#
# - argument: Argument to test
# - type: Type to check
# *Returns* Wether the argument is of the given type
func _is_type(argument, type: int) -> bool:
	return typeof(argument) == type
		
