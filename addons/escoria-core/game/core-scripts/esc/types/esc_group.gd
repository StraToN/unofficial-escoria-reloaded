# A group of ESC commands
extends ESCStatement
class_name ESCGroup


# A RegEx identifying a group
const REGEX = '^([^>]*)>\\s*(\\[(?<conditions>[^\\]]+)\\])?$'


# A list of ESCConditions to run this group
# Conditions are combined using logical AND
var conditions: Array = []

# The list of ESC commands
var statements: Array = []


# Construct an ESC group of an ESC script line
func _init(group_string: String):
	var group_regex = RegEx.new()
	group_regex.compile(REGEX)
	
	if group_regex.search(group_string):
		for result in group_regex.search_all(group_string):
			if "conditions" in result.names:
				for condition in escoria.utils._get_re_group(
						result, 
						"conditions"
					).split(","):
					self.conditions.append(
						ESCCondition.new(condition)
					)
	else:
		escoria.logger.report_errors(
			"Invalid group detected: %s" % group_string,
			[
				"Group regexp didn't match"
			]
		)


# Runs all commands in this group
func run() -> int:
	for statement in self.statements:
		if statement.is_valid():
			var rc=statement.run()
			if rc == ESCExecution.RC_REPEAT:
				return self.run()
			elif rc != ESCExecution.RC_OK:
				return rc
	return ESCExecution.RC_OK
