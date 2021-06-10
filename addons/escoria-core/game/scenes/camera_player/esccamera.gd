extends Camera2D
class_name ESCCamera

onready var tween = $"tween"

var default_limits = {}  # This does not change once set

var speed = 0.0
# Target can be object or Vector2. See resove_target_pos()
var target
var target_pos : Vector2

var zoom_time
var zoom_target

# This is needed to adjust dialog positions and such, see dialog_instance.gd
var zoom_transform


"""
Sets camera limits so it doesn't go out of the scene. If kwargs is null, default
limits are used. See Camera2D limits for more details.
- kwargs Dictionary (can be null) Limits to set.
	- limit_left int Left limit.
	- limit_right int Right limit.
	- limit_top int Top limit.
	- limit_bottom int Bottom limit.
	- set_default bool (Facultative) If true, the given limits are save as default limits.
"""
func set_limits(kwargs=null):
	if not kwargs:
		kwargs = {
			"limit_left": -10000,
			"limit_right": 10000,
			"limit_top": -10000,
			"limit_bottom": 10000,
			"set_default": false,
		}
		print_stack()

	self.limit_left = kwargs["limit_left"]
	self.limit_right = kwargs["limit_right"]
	self.limit_top = kwargs["limit_top"]
	self.limit_bottom = kwargs["limit_bottom"]

	if "set_default" in kwargs and kwargs["set_default"] and not default_limits:
		default_limits = kwargs

func resolve_target_pos():
	if typeof(target) == TYPE_VECTOR2:
		target_pos = target
	elif typeof(target) == TYPE_ARRAY:
		var count = 0

		for obj in target:
			target_pos += obj.get_camera_pos()
			count += 1

		# Let the error in if an empty array was passed (divzero)
		target_pos = target_pos / count
	else:
		target_pos = target.get_camera_pos()

	return target_pos

func set_drag_margin_enabled(p_dm_h_enabled, p_dm_v_enabled):
	self.drag_margin_h_enabled = p_dm_h_enabled
	self.drag_margin_v_enabled = p_dm_v_enabled


func set_target(p_target, p_speed : float = 0.0):
	speed = p_speed
	target = p_target

	resolve_target_pos()
	escoria.logger.info("Current camera position = " + str(self.global_position))

	if speed == 0.0:
		self.global_position = target_pos
	else:
		var time = self.global_position.distance_to(target_pos) / speed

		if tween.is_active():
			var tweenstat = String(tween.tell()) + "/" + String(tween.get_runtime())
			escoria.logger.report_warnings("camera.gd:set_target()", 
				["Tween still active running camera_set_target: " + tweenstat])
			tween.emit_signal("tween_completed")

		tween.interpolate_property(self, "global_position", self.global_position, 
			target_pos, time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()

func set_camera_zoom(p_zoom_level, p_time):
	if p_zoom_level <= 0.0:
		escoria.logger.report_errors("camera.gd:set_camera_zoom()", 
			["Tried to set negative or zero zoom level"])

	zoom_time = p_time
	zoom_target = Vector2(1, 1) * p_zoom_level

	if zoom_time == 0:
		self.zoom = zoom_target
	else:
		if tween.is_active():
			var tweenstat = String(tween.tell()) + "/" + String(tween.get_runtime())
			escoria.logger.report_warnings("camera", 
				["Tween still active running camera_set_zoom: " + tweenstat])
			tween.emit_signal("tween_completed")

		tween.interpolate_property(self, "zoom", self.zoom, zoom_target, 
			zoom_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()


func push(p_target, p_time, p_type):
	var time = float(p_time)
	var type = "TRANS_" + p_type

	target = p_target

	var camera_pos
	var camera_pos_coords
	if target.has_node("camera_pos"):
		camera_pos = target.get_node("camera_pos")
		camera_pos_coords = camera_pos.global_position
	else:
		camera_pos_coords = target.global_position

	if time == 0:
		self.global_position = camera_pos_coords

		if camera_pos and camera_pos is Camera2D:
			self.zoom = camera_pos.zoom
	else:
		if tween.is_active():
			var tweenstat = String(tween.tell()) + "/" + String(tween.get_runtime())
			escoria.logger.report_warnings("camera", 
				["Tween still active running camera_push: " + tweenstat])
			tween.emit_signal("tween_completed")

		if camera_pos and camera_pos is Camera2D:
			tween.interpolate_property(self, "zoom", self.zoom, camera_pos.zoom, 
				time, tween.get(type), Tween.EASE_IN_OUT)

		tween.interpolate_property(self, "global_position", self.global_position, 
			camera_pos_coords, time, tween.get(type), Tween.EASE_IN_OUT)
		tween.start()


func shift(p_x, p_y, p_time, p_type):
	var x = int(p_x)
	var y = int(p_y)
	var time = float(p_time)
	var type = "TRANS_" + p_type

	var new_pos = self.global_position + Vector2(x, y)
	target = new_pos

	if tween.is_active():
		var tweenstat = String(tween.tell()) + "/" + String(tween.get_runtime())
		escoria.logger.report_warnings("camera", 
			["Tween still active running camera_shift: " + tweenstat])
		tween.emit_signal("tween_completed")
	
	tween.interpolate_property(self, "global_position", self.global_position, 
		new_pos, float(time), tween.get(type), Tween.EASE_IN_OUT)
	tween.start()


func target_reached():
	tween.stop_all()

func _process(_delta):
	zoom_transform = self.get_canvas_transform()

	if target and not tween.is_active():
		if typeof(target) == TYPE_VECTOR2 or typeof(target) == TYPE_ARRAY:
			self.global_position = resolve_target_pos()
		elif "moved" in target and target.moved \
		or "moved" in target.movable and target.movable.moved:
			self.global_position = resolve_target_pos()

func _ready():
	if not target:
		target = Vector2(0, 0)

	tween.connect("tween_completed", self, "target_reached")
	escoria.object_manager.register_object(
		ESCObject.new(
			self.name,
			self
		),
		true
	)

