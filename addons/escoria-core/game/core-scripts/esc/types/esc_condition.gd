# A condition to run a command
extends Object
class_name ESCCondition


# Valid comparison types
enum {COMPARISON_NONE, COMPARISON_EQ, COMPARISON_GT, COMPARISON_LT}


# Regex that matches condition lines
const REGEX = \
	'^(?<is_negated>!)?(?<comparison>eq|gt|lt)? ?' +\
	'(?<is_inventory>i\/)?(?<flag>[^ ]+)( (?<comparison_value>[\\d]+))?$'


# Name of the flag compared
var flag: String

# Wether this condition is negated
var negated: bool = false

# Wether this condition is regarding an inventory item ("i/...")
var inventory: bool = false

# An optional comparison type. Use the COMPARISON-Enum
var comparison: int = COMPARISON_NONE

# The value used together with the comparison type
var comparison_value: int = 0


# Create a new condition from an ESC condition string
func _init(comparison_string: String):
	var comparison_regex = RegEx.new()
	comparison_regex.compile(
		REGEX
	)
	
	if comparison_regex.search(comparison_string):
		for result in comparison_regex.search_all(comparison_string):
			if "is_negated" in result.names:
				self.negated = true
			if "comparison" in result.names:
				match escoria.utils._get_re_group(result, "comparison"):
					"eq": self.comparison = COMPARISON_EQ
					"gt": self.comparison = COMPARISON_GT
					"lt": self.comparison = COMPARISON_LT
					_: escoria.logger.report_errors(
						"Invalid comparison type detected: %s" % 
								comparison_string,
						[
							"Comparison type %s unknown" % 
									escoria.utils._get_re_group(
										result, 
										"comparison"
									)
						]
					)
			if "comparison_value" in result.names:
				self.comparison_value = int(
					escoria.utils._get_re_group(result, "comparison_value")
				)
			if "is_inventory" in result.names:
				self.inventory = true
			if "flag" in result.names:
				self.flag = escoria.utils._get_re_group(result, "flag")
	else:
		escoria.logger.report_errors(
			"Invalid comparison detected: %s" % comparison_string,
			[
				"Comparison regexp didn't match"
			]
		)
		

# Run this comparison against the globals
func run(globals: Dictionary) -> bool:
	var global_name = flag
	
	if self.inventory:
		global_name = "i/%s" % flag
		
	var return_value = false
	
	if comparison == COMPARISON_NONE and global_name in globals:
		return_value = true
	elif comparison == COMPARISON_EQ and\
			globals[global_name] == comparison_value:
		return_value = true
	elif comparison == COMPARISON_GT and\
			globals[global_name] > comparison_value:
		return_value = true
	elif comparison == COMPARISON_LT and\
			globals[global_name] < comparison_value:
		return_value = true
		
	if negated:
		return not return_value
	
	return return_value
