extends Control

signal back_button_pressed

export(PackedScene) var slot_ui_scene

func _ready():
	$slots/autosave_slot.disabled = true
	var datetime = OS.get_datetime()
	var datetime_string = "%s/%s/%s %s:%s" % [
		datetime["day"],
		datetime["month"],
		datetime["year"],
		datetime["hour"],
		datetime["minute"],
	]
	$slots/autosave_slot.set_slot_name_date("Autosave", datetime_string)


func _on_slot_pressed(p_slot_n : int):
#	if !escoria.can_save():
#		return # maybe show an error? the vm is not ready to save
	escoria.save_data.save_game(p_slot_n)


#func get_save_data() -> Array:
#	if escoria.event_manager.events_queue.size() != 0:
#		return []
#
#	var ret = []
#	var load_event = ESCEvent.new(":load")
#	load_event.statements.append_array(
#		[
#			ESCCommand.new("cut_scene telon fade_out"),
#			ESCCommand.new("change_scene %s false" \
#				% escoria.main.current_scene.get_filename())
#		]
#	)
#	load_event.statements.append(ESCCommand.new("##Global flags"))
#	for k in escoria.globals_manager._globals.keys():
#		if !escoria.globals_manager._globals[k]:
#			continue
#		load_event.statements.append(
#			ESCCommand.new("set_global %s \"%s\"\n" \
#				% [k, escoria.globals_manager._globals[k]])
#		)
#	ret.append(load_event)
	
#
#
#	ret.append("## Objects\n\n")
#	var objs = {}
#	for k in states.keys():
#		objs[k] = true
#	for k in actives.keys():
#		objs[k] = true
#	for k in interactives.keys():
#		objs[k] = true
#	for k in objs.keys():
#		if k in actives:
#			var s = "true"
#			if !actives[k]:
#				s = "false"
#			ret.append("set_active " + k + " " + s + "\n")
#
#		if k in interactives:
#			var s = "true"
#			if !interactives[k]:
#				s = "false"
#			ret.append("set_interactive " + k + " " + s + "\n")
#
#		if k in states && states[k] != "default":
#			ret.append("set_state " + k + " " + states[k] + "\n")
#
#		ret.append("\n")
#
#	# check global states of moved objects
#	for k in objects:
#		if k == "player" || objects[k] == null:
#			continue
#
#		if "moved" in objects[k] and objects[k].moved:
#			var pos = objects[k].get_position()
#			ret.append("teleport_pos " + k + " " + str(int(pos.x)) + " " + str(int(pos.y)) + "\n")
#			if objects[k].last_deg != null:
#				if objects[k].last_deg < 0 or objects[k].last_deg > 360:
#					report_errors("global_vm", ["Trying to save game with " + objects[k].name + " at invalid angle " + str(objects[k].last_deg)])
#				ret.append("set_angle " + k + " " + str(objects[k].last_deg) + "\n")
#
#	ret.append("\n")
#	ret.append("## Player\n\n")
#
#	if main.get_current_scene().has_node("player"):
#		var player = main.get_current_scene().get_node("player")
#		var pos = player.get_global_position()
#		var angle = player.last_deg
#		ret.append("teleport_pos player " + str(pos.x) + " " + str(pos.y) + "\n")
#		# Angle may be unset if saving occurs when entering another room
#		if angle:
#			if angle < 0 or angle > 360:
#				report_errors("global_vm", ["Trying to save game with player at invalid angle " + str(angle)])
#			ret.append("set_angle player " + str(angle) + "\n")
#
#	ret.append("\n")
#	ret.append("## Camera\n\n")
#	if cam_target != null:
#		if typeof(cam_target) == TYPE_VECTOR2:
#			ret.append("camera_set_pos 0 " + str(int(cam_target.x)) + " " + str(int(cam_target.y)) + "\n")
#		else:
#			var tlist = ""
#
#			if typeof(cam_target) == TYPE_ARRAY:
#				for t in cam_target:
#					tlist = tlist + " " + t
#			elif typeof(cam_target) == TYPE_STRING:
#				var target_obj = get_object(cam_target)
#
#				if "global_id" in target_obj:
#					tlist = tlist + " " + target_obj.global_id
#				elif cam_target == "player":
#					tlist = tlist + " player"
#				else:
#					report_warnings("global_vm", ["Unknown cam_target " + str(cam_target) + ", defaulting to player"])
#					tlist = tlist + " player"
#			elif cam_target is esc_type.PLAYER:
#				tlist = tlist + " player"
#			else:
#				report_errors("global_vm", ["Messed up cam_target " + str(cam_target)])
#
#			ret.append("camera_set_target 0" + tlist + "\n")
#
#	if customs:
#		ret.append("\n")
#		ret.append("## Custom\n\n")
#
#		for custom in customs:
#			ret.append(custom + "\n")
#
#		ret.append("\n")
#
#	# Always save the zoom, but assume symmetrical zoom because esc scripts don't support anything else
#	ret.append("camera_set_zoom " + str(camera.zoom.x) + "\n")
#
#	for e in event_queue:
#		ret.append("sched_event " + str(e.qe_time) + " " + e.qe_objname + " " + e.qe_event + "\n")
#
#	ret.append("\ncut_scene telon fade_in\n")
#
#	emit_signal("saved")
#	return ret


func _on_back_pressed():
	emit_signal("back_button_pressed")
