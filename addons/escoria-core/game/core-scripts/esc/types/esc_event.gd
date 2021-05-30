# An ESC event
extends Object
class_name ESCEvent


# Emitted when the event did finish running
signal event_finished(return_code)


# Regex identifying an ESC event
const REGEX = \
	'^:(?<name>[^\\s]+)( \\|(?<flags>( ' +\
	'(TK|NO_TT|NO_HUD|NO_SAVE|CUT_BLACK|LEAVE_BLACK)' +\
	')+))?$'


# Valid event flags
# * TK: stands for "telekinetic". It means the player won't walk over to 
#   the item to say the line.
# * NO_TT: stands for "No tooltip". It hides the tooltip for the duration of 
#   the event. Probably not very useful, because events having multiple
#   say commands in them are automatically hidden.
# * NO_HUD: stands for "No HUD". It hides the HUD for the duration of the
#   event. Useful when you want something to look like a cut scene but not 
#   disable input for skipping dialog.
# * NO_SAVE: disables saving. Use this in cut scenes and anywhere a 
#   badly-timed autosave would leave your game in a messed-up state.
# * CUT_BLACK: applies only to `:setup`. It makes the screen go black 
#   during the setup phase. You will probably see a quick black flash, so use 
#   it only if you prefer it over the standard cut.
# * LEAVE_BLACK: applies only to `:setup`. In case your `:ready` starts with 
#   `cut_scene telon fade_in`, you must apply this flag or you will see a 
#  flash of your new scene before going black again for the fade_in.
enum {
	FLAG_TK = 1, 
	FLAG_NO_TT = 2, 
	FLAG_NO_HUD = 4, 
	FLAG_NO_SAVE = 8, 
	FLAG_CUT_BLACK = 16, 
	FLAG_LEAVE_BLACK = 32
}


# Name of event
var name: String

# Flags set to this event
var flags: int = 0

# The list of ESC statements
var statements: Array = []


# Create a new event from an event line
func _init(event_string: String):
	var event_regex = RegEx.new()
	event_regex.compile(REGEX)
	
	if event_regex.search(event_string):
		for result in event_regex.search_all(event_string):
			if "name" in result.names:
				self.name = escoria.utils._get_re_group(result, "name")
			if "flags" in result.names:
				var _flags = escoria.utils._get_re_group(
						result, 
						"flags"
					).strip_edges().split(" ")
				if "TK" in _flags:
					self.flags |= FLAG_TK
				if "NO_TT" in _flags:
					self.flags |= FLAG_NO_TT
				if "NO_HUD" in _flags:
					self.flags |= FLAG_NO_HUD
				if "NO_SAVE" in _flags:
					self.flags |= FLAG_NO_SAVE
				if "CUT_BLACK" in _flags:
					self.flags |= FLAG_CUT_BLACK
				if "LEAVE_BLACK" in _flags:
					self.flags |= FLAG_LEAVE_BLACK
	else:
		escoria.logger.report_errors(
			"Invalid event detected: %s" % event_string,
			[
				"Event regexp didn't match"
			]
		)


# Runs all commands, groups or dialogs in this event
# **Returns** one of the ESCEventManager return codes
func run() -> int:
	for statement in statements:
		if statement.is_valid():
			var rc = statement.run()
			if rc == ESCExecution.RC_REPEAT:
				return self.run()
			elif rc != ESCExecution.RC_OK:
				return rc
	return ESCExecution.RC_OK
