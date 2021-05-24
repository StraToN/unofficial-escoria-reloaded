
# Helpers to deal with player's and items' angles
func _get_deg_from_rad(rad_angle : float):
	var deg = rad2deg(rad_angle)
	if deg >= 360.0:
		deg = clamp(deg, 0.0, 360.0)
		if deg == 360.0:
			deg = 0.0
	return deg


# Get the content of a reg exp group by name
func _get_re_group(re_match: RegExMatch, group: String) -> String:
	if group in re_match.names:
		return re_match.strings[re_match.names[group]]
	else:
		return ""
