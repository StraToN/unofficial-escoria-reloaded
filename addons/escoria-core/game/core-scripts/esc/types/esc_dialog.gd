# An ESC dialog
extends Object
class_name ESCDialog


# Regex that matches dialog lines
const REGEX = \
	'^([^?]*)\\?( (?<type>[^ ]+))?( (?<avatar>[^ ]+))?' +\
	'( (?<timeout>[^ ]+))?( (?<timeout_option>.+))?$'


# A Regex that matches the end of a dialog
const END_REGEX = \
	'^([^!]*)!'


# Dialog type
var type: String = ""

# Avatar used in the dialog
var avatar: String = ""

# Timeout until the timeout_option option is selected. Use 0 for no timeout
var timeout: int = 0

# The dialog option to select when timeout is reached
var timeout_option: int = 0

# A list of ESCDialogOptions
var options: Array


# Construct a dialog from a dialog string
func _init(dialog_string: String):
	var dialog_regex = RegEx.new()
	dialog_regex.compile(REGEX)
	
	if dialog_regex.search(dialog_string):
		for result in dialog_regex.search_all(dialog_string):
			if "type" in result.names:
				self.type = escoria.utils._get_re_group(result, "type")
			if "avatar" in result.names:
				self.avatar = escoria.utils._get_re_group(result, "avatar")
			if "timeout" in result.names:
				self.timeout = int(
					escoria.utils._get_re_group(result, "timeout")
				)
			if "timeout_option" in result.names:
				self.timeout_option = int(
					escoria.utils._get_re_group(result, "timeout_option")
				)
	else:
		escoria.logger.report_errors(
			"Invalid dialog detected: %s" % dialog_string,
			[
				"Dialog regexp didn't match"
			]
		)
