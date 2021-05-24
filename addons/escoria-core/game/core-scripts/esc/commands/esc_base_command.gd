# A base class for every ESC command.
# Extending classes have to override the configure and run function
extends Object
class_name ESCBaseCommand


# Return the descriptor of the arguments of this command
func configure() -> ESCCommandArgumentDescriptor:
	escoria.logger.error("Command %s did not override configure." % get_class())
	return ESCCommandArgumentDescriptor.new()
	

# Validate wether the given arguments match the command descriptor
func validate(arguments: Array):
	self.configure().validate(get_class(), arguments)


# Run the command
func run(current_context: Dictionary, command_params: Array) -> int:
	escoria.logger.error("Command %s did not override run." % get_class())
	return 0
