
# Helpers to deal with player's and items' angles
func _get_deg_from_rad(rad_angle : float):
	var deg = rad2deg(rad_angle)
	if deg >= 360.0:
		deg = clamp(deg, 0.0, 360.0)
		if deg == 360.0:
			deg = 0.0
	return deg


# Get the content of a reg exp group by name
#
# #### Parameters
#
# - re_match: The RegExMatch object
# - group: The name of the group
# **Returns** The value of the named regex group in the match
func _get_re_group(re_match: RegExMatch, group: String) -> String:
	if group in re_match.names:
		return re_match.strings[re_match.names[group]]
	else:
		return ""


# Return a string value in the correct infered type
#
# #### Parameters
#
# - value: The original value
# **Returns** The typed value according to the type inference
func get_typed_value(value: String):
	var regex_bool = RegEx.new()
	regex_bool.compile("^true|false$")
	var regex_float = RegEx.new()
	regex_float.compile("^[0-9]+\\.[0-9]+$")
	var regex_int = RegEx.new()
	regex_int.compile("^[0-9]+$")
	
	if regex_float.search(value):
		return float(value)
	elif regex_int.search(value):
		return int(value)
	elif regex_bool.search(value.to_lower()):
		return bool(value.to_lower())
	else:
		return str(value)
