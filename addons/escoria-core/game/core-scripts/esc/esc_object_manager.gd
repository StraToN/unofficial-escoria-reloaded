# A manager for ESC objects
extends Node
class_name ESCObjectManager


# The hash of registered objects (the global id is the key)
var objects: Dictionary = {}


# Make active objects visible
func _process(_delta):
	for object in objects:
		if (object as ESCObject).node:
			(object as ESCObject).node.visible = (object as ESCObject).active


# Register the object in the manager
func register_object(object: ESCObject, force: bool = false) -> void:
	if objects.has(object.global_id) and not force:
		escoria.logger.report_errors(
			"ESCObjectManager.register_object: Object already registered",
			[
				"Object with global id %s already registered" % 
						object.global_id
			]
		)
	else:
		objects[object.global_id] = object


# Get the object from the object registry
func get_object(global_id: String) -> ESCObject:
	if objects.has(global_id):
		return objects[global_id]
	else:
		escoria.logger.report_errors(
			"Invalid object retrieved",
			[
				"Object with global id %s not found" % global_id
			]
		)
		return null
