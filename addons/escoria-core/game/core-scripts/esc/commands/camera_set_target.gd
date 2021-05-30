# `camera_set_target speed object`
#
# Configures the camera to follow 1 or more objects, using "speed" as speed 
# limit. This is the default behavior (default follow object is "player"). If 
# there's more than 1 object, the camera follows the average position of all 
# the objects specified.
#
# @ESC
extends ESCBaseCommand
class_name CameraSetTargetCommand


# Return the descriptor of the arguments of this command
func configure() -> ESCCommandArgumentDescriptor:
	return ESCCommandArgumentDescriptor.new(
		2, 
		[TYPE_REAL, TYPE_STRING],
		[null, null]
	)
	

# Validate wether the given arguments match the command descriptor
func validate(arguments: Array):
	if not escoria.object_manager.objects.has(arguments[0]):
		escoria.logger.report_errors(
			"camera_set_pos: invalid object",
			[
				"Object with global id %s not found" % arguments[0]
			]
		)
		return false
	
	return .validate(arguments)


# Run the command
func run(command_params: Array) -> int:
	(escoria.object_manager.get_object("camera").node as ESCCamera)\
		.set_target(
			command_params[0],
			command_params[1]
		)
	return ESCExecution.RC_OK
