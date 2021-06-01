# An ESC command
extends ESCStatement
class_name ESCCommand


# Regex matching command lines
const REGEX = \
	'^(\\s*)(?<name>[^\\s]+)(\\s(?<parameters>([^\\[]|$)+))?' +\
	'(\\[(?<conditions>[^\\]]+)\\])?'


# The name of this command
var name: String

# Parameters of this command
var parameters: Array = []

# A list of ESCConditions to run this command.
# Conditions are combined using logical AND
var conditions: Array = []


# Create a command from a command string
func _init(command_string):
	var command_regex = RegEx.new()
	command_regex.compile(REGEX)
	
	if command_regex.search(command_string):
		for result in command_regex.search_all(command_string):
			if "name" in result.names:
				self.name = escoria.utils._get_re_group(result, "name")
			if "parameters" in result.names:
				# Split parameters by whitespace but allow quoted 
				# parameters
				var quote_open = false
				var parameter_values = PoolStringArray([])
				for parameter in escoria.utils._get_re_group(
						result, 
						"parameters"
					).strip_edges().split(" "):
					if parameter.begins_with('"') and parameter.ends_with('"'):
						parameters.append(
							parameter.substr(1, parameter.length() - 2)
						)
					elif parameter.begins_with('"'):
						quote_open = true
						parameter_values.append(parameter.substr(1))
					elif parameter.ends_with('"'):
						quote_open = false
						parameter_values.append(
							parameter.substr(0, len(parameter) - 1)
						)
						parameters.append(parameter_values.join(" "))
						parameter_values.resize(0)
					elif quote_open:
						parameter_values.append(parameter)
					else:
						parameters.append(parameter)
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
			"Invalid command detected: %s" % command_string,
			[
				"Command regexp didn't match"
			]
		)


# Check, if conditions match
func is_valid() -> bool:
	for base_path in ProjectSettings.get("escoria/esc/command_paths"):
		var command_path = "%s/%s.gd" % [
			base_path,
			self.name
		]
			
	return .is_valid()
	

# Run this command
func run() -> int:
	escoria.logger.debug("Running command %s" % self.name)
	var command_object = escoria.command_registry.get_command(self.name)
	if command_object == null:
		return ESCExecution.RC_ERROR
	else:
		var argument_descriptor = command_object.configure()
		var prepared_arguments = argument_descriptor.prepare_arguments(
			self.parameters
		)
		if argument_descriptor.validate(self.name, prepared_arguments):
			var rc = command_object.run(prepared_arguments)
			if rc is GDScriptFunctionState:
				rc = yield(rc, "completed")
			escoria.logger.debug("[%s] Return code: %d" % [self.name, rc])
			return rc
		else:
			return ESCExecution.RC_ERROR