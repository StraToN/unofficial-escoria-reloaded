# An object handled in Escoria
extends Node
class_name ESCObject


# The global id of the object
var global_id: String

# Wether the object is active (visible to the player)
var active: bool = true

# Wether the object is interactive (clickable by the player)
var interactive: bool = true

# The state of the object. If the object has a respective animation, 
# it will be played
var state: String = "default"

# The events registered with the object
var events: Dictionary = {}

# The node in the scene. Can be an ESCItem or an ESCCamera
var node: Node


func _init(p_global_id: String, p_node: Node):
	global_id = p_global_id
	node = p_node


# Set the state and start a possible animation
#
# #### Parameters
#
# - p_state: State to set
# - immediate: If true, skip directly to the end
func set_state(p_state: String, immediate: bool = false):
	state = p_state
	
	if node.has_method("get_animation_player"):
		var animation_node = node.get_animation_player()
	
		if animation_node:
			animation_node.stop()
			var actual_animator
			if animation_node is AnimationPlayer:
				if animation_node.has_animation(p_state):
					if immediate:
						animation_node.current_animation = p_state
						animation_node.seek(
							animation_node.get_animation(p_state).length
						)
					else:
						animation_node.play(p_state)
			elif animation_node is AnimatedSprite:
				if animation_node.frames.has_animation(p_state):
					if immediate:
						animation_node.animation = p_state
						animation_node.frame = \
							animation_node.frames.get_frame_count(p_state)
					else:
						animation_node.play(p_state)
