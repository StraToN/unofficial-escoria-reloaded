# `camera_set_zoom magnitude [time]`
#
# Zooms the camera in/out to the desired `magnitude`. Values larger than 1 zooms 
# the camera out, and smaller values zooms in, relative to the default value 
# of 1. An optional `time` in seconds controls how long it takes for the camera 
# to zoom into position.
#
# @ESC
extends ESCBaseCommand
class_name CameraSetZoomCommand


# Return the descriptor of the arguments of this command
func configure() -> ESCCommandArgumentDescriptor:
	return ESCCommandArgumentDescriptor.new(
		1, 
		[TYPE_INT, TYPE_REAL],
		[null, 0.0]
	)


# Run the command
func run(current_context: Dictionary, command_params: Array) -> int:
	(escoria.object_manager.get_object("camera").node as ESCCamera)\
		.set_camera_zoom(
			command_params[0],
			command_params[1]
		)
	return ESCEventManager.RC_OK
