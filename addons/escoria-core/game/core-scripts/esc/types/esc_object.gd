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
var state: String = "default" setget _set_state

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
func _set_state(p_state: String):
	state = p_state
	
	var animation_node = null
	
	if node.has("get_animation_player"):
		animation_node = node.get_animation_player()
	
	if animation_node:
		animation_node.stop()
		var actual_animator
		if animation_node is AnimationPlayer:
			actual_animator = animation_node
		elif animation_node is AnimatedSprite:
			actual_animator = animation_node.frames
			
		if actual_animator.has_animation(p_state):
			animation_node.play(p_state)
