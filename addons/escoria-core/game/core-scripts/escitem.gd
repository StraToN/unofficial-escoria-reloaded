tool
extends Area2D
class_name ESCItem

"""
ESCItem is a Sprite that defines an item, potentially interactive
"""

signal mouse_entered_item(item)
signal mouse_exited_item(item)
signal mouse_left_clicked_item(global_id)
signal mouse_double_left_clicked_item(global_id)
signal mouse_right_clicked_item(global_id)

var Movable
var MovableScript = load("res://addons/escoria-core/game/core-scripts/behaviors/movable.gd")

export(String) var global_id
export(String, FILE, "*.esc") var esc_script

# If true, the ESC script may have an ":exit_scene" event to manage scene changes
export(bool) var is_exit

# is_trigger If true, object is considered as trigger. Allows using :trigger_in and
# :trigger_out verbs in ESC scripts. 
export(bool) var is_trigger
export(String) var trigger_in_verb = "trigger_in"
export(String) var trigger_out_verb = "trigger_out"

# is_interactive : If true, object is not "focusable".
export(bool) var is_interactive = true

# player_orients_on_arrival : If true, player orients towards 'interaction_direction' as
# player character arrives.
export(bool) var player_orients_on_arrival = true

export(ESCPlayer.Directions) var interaction_direction
export(String) var tooltip_name

# Default action to use if object is not in the inventory
export(String) var default_action
# Default action to use if object is in the inventory
export(String) var default_action_inventory

# If action used by player is in the list, game will wait for a second click on another item
# to combine objects together (typical USE <X> WITH <Y>, GIVE <X> TO <Y>)
export(PoolStringArray) var combine_if_action_used_among = []
# If true, combination must be done in the way it is written in ESC script
# ie. :use ON_ITEM
# If false, combination will be tried in the other way.
export(bool) var combine_is_one_way = false
# If use_from_inventory_only is true, then the object must have been picked up before using it.
# A false value is useful for items in the background, such as buttons.
export(bool) var use_from_inventory_only = false
# Scene used in inventory for the object if it is picked up
export(PackedScene) var inventory_item_scene_file : PackedScene 

# Color used for dialogs
export(Color) var dialog_color = ColorN("white")


# Detected interact position set by a Position2D node OUTSIDE OF THE SCENE.
# You have to add a child to the INSTANCED SCENE, IN THE ROOM SCENE.
#var interact_positions : Dictionary = { "default": null}

# Animation node (null if none was found)
var animation_sprite

# Animations script (for walking, idling...)
export(Script) var animations

# TERRAIN
var terrain : ESCTerrain
# If the terrain node type is scalenodes
var terrain_is_scalenodes : bool
var check_maps = true
var collision
# If dont_apply_terrain_scaling is true, terrain scaling will not be applied and
# node will remain at the scale set in the scene.
export(bool) var dont_apply_terrain_scaling = false

export(int) var speed : int = 300
export(float) var v_speed_damp : float = 1.0
var orig_speed : float

enum PLAYER_TASKS {
	NONE,
	WALK,
	SLIDE
}
onready var task = PLAYER_TASKS.NONE # type PLAYER_TASKS
var params_queue : Array 


# PRIVATE VARS
# Size of the item
var size : Vector2
var last_deg : int
var last_dir : int


func _ready():
	# Adds movable behavior
	Movable = Node.new()
	Movable.set_script(MovableScript)
	add_child(Movable)
	
	for n in get_children():
		if n is AnimatedSprite:
			animation_sprite = n
			continue
		if n is AnimationPlayer:
			animation_sprite = n
			continue
	
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	connect("input_event", self, "manage_input")
	
	# Initialize collision variable.
	for c in get_children():
		if c is CollisionShape2D or c is CollisionPolygon2D:
			collision = c
	
	# Register and connect all elements to Escoria backoffice.
	if !Engine.is_editor_hint():
		escoria.object_manager.register_object(ESCObject.new(
			global_id,
			self
		))
		terrain = escoria.room_terrain
		
		if !is_trigger:
			connect("mouse_entered_item", escoria.inputs_manager, "_on_mouse_entered_item")
			connect("mouse_exited_item", escoria.inputs_manager, "_on_mouse_exited_item")
			connect("mouse_left_clicked_item", escoria.inputs_manager, "_on_mouse_left_clicked_item")
			connect("mouse_double_left_clicked_item", escoria.inputs_manager, "_on_mouse_left_double_clicked_item")
			connect("mouse_right_clicked_item", escoria.inputs_manager, "_on_mouse_right_clicked_item")
		else:
			connect("area_entered", self, "element_entered")
			connect("area_exited", self, "element_exited")
			connect("body_entered", self, "element_entered")
			connect("body_exited", self, "element_exited")
		
	# If object can be in the inventory, set default_action_inventory to same as
	# default_action, if default_action_inventory is not set
	if use_from_inventory_only and default_action_inventory.empty():
		default_action_inventory = default_action
	
	# Perform a first terrain scaling if we have to.
	if !is_exit or dont_apply_terrain_scaling:
		Movable.last_scale = scale
		Movable.update_terrain()


func get_animation_player():
	if animation_sprite == null:
		for n in get_children():
			if n is AnimationPlayer:
				animation_sprite = n
	return animation_sprite


#"""
#Initialize the interact_position attribute by searching for a Position2D
#node in children nodes. 
#If any is found, the first one is used as interaction position with this hotspot.
#If none is found, we use the CollisionShape2D or CollisionPolygon2D child node's 
#position instead.
#"""
#func init_interact_position_with_node():
#	interact_positions.default = null
#	for c in get_children():
#		if c is Position2D:
#			# If the position2D node is part of the hotspot, it means it is not an interact position
#			# but a dialog position for example. Interact position node must be set in the room scene.
#			if c.get_owner() == self:
#				continue
#			var globalpos = c.global_position
#			interact_positions.default = c.global_position
#
#		if c is CollisionShape2D or c is CollisionPolygon2D:
#			collision = c
#			if interact_positions.default == null:
#				interact_positions.default = c.global_position

func get_interact_position() -> Vector2:
	var interact_position = null
	for c in get_children():
		if c is Position2D:
			# If the position2D node is part of the hotspot, it means it is not an interact position
			# but a dialog position for example. Interact position node must be set in the room scene.
			if c.get_owner() == self:
				continue
			interact_position = c.global_position
			
		if c is CollisionShape2D or c is CollisionPolygon2D:
			if interact_position == null:
				interact_position = c.global_position
		
	return interact_position

	
	
func manage_input(viewport : Viewport, event : InputEvent, shape_idx : int):
	if event is InputEventMouseButton:
				
		if event.doubleclick:
			if event.button_index == BUTTON_LEFT:
				emit_signal("mouse_double_left_clicked_item", self, event)
		else:
			if event.is_pressed():
				if event.button_index == BUTTON_LEFT:
					emit_signal("mouse_left_clicked_item", self, event)
				elif event.button_index == BUTTON_RIGHT:
					emit_signal("mouse_right_clicked_item", self, event)
		

func _on_mouse_entered():
	emit_signal("mouse_entered_item", self)

func _on_mouse_exited():
	emit_signal("mouse_exited_item",  self)

################################################################################

# TRIGGER functions 

func element_entered(body):
	if body is ESCBackground or body.get_parent() is ESCBackground:
		return
	escoria.do("trigger_in", [global_id, body.global_id, trigger_in_verb])


func element_exited(body):
	if body is ESCBackground or body.get_parent() is ESCBackground:
		return
	escoria.do("trigger_out", [global_id, body.global_id, trigger_out_verb])

################################################################################

# MOVING OBJECT functions

func teleport(target, angle : Object = null) -> void:
	Movable.teleport(target, angle)

func walk_to(pos : Vector2, p_walk_context = null) -> void:
	Movable.walk_to(pos, p_walk_context)

func set_speed(speed_value : int) -> void:
	speed = speed_value

################################################################################

# TALKATIVE object functions

func start_talking():
#	if animation_sprite.is_playing():
#		animation_sprite.stop()
#	animation_sprite.play(animations.speaks[last_dir][0])
	pass

func stop_talking():
#	if animation_sprite.is_playing():
#		animation_sprite.stop()
	pass
