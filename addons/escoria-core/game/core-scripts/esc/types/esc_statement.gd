# A statement in an ESC file
extends Object
class_name ESCStatement


# Check wether the statement should be run based on its conditions
func is_valid() -> bool:
	return false
	
	
# Execute this statement and return its return code
func run() -> int:
	return ESCExecution.RC_ERROR
