# `camera_set_pos speed x y`
#
# Moves the camera to a position defined by "x" and "y", at the speed defined 
# by "speed" in pixels per second. If speed is 0, camera is teleported to the 
# position.
#
# @ESC
extends ESCBaseCommand
class_name CameraSetPosCommand


# Return the descriptor of the arguments of this command
func configure() -> ESCCommandArgumentDescriptor:
	return ESCCommandArgumentDescriptor.new(
		3, 
		[TYPE_REAL, TYPE_REAL, TYPE_REAL],
		[null, null, null]
	)


# Run the command
func run(current_context: Dictionary, command_params: Array) -> int:
	(escoria.object_manager.get_object("camera").node as ESCCamera)\
			.set_target(
				Vector2(command_params[0], command_params[1]), 
				command_params[2]
			)
	return ESCEventManager.RC_OK
