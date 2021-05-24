# Logging framework for Escoria


# The path of the ESC file that was reported last (used for removing
# duplicate warnings
var warning_path : String


# Valid log levels
enum { LOG_ERROR, LOG_WARNING, LOG_INFO, LOG_DEBUG }


# Log a debug message
#
# #### Parameters
# 
# * string: Text to log
# * args: Additional information
func debug(string : String, args = []):
	if ProjectSettings.get("escoria/debug/log_level") >= LOG_DEBUG:
		var argsstr = str(args) if !args.empty() else ""
		printerr("(D)\t" + string + " \t" + argsstr)


# Log an info message
#
# #### Parameters
# 
# * string: Text to log
# * args: Additional information
func info(string : String, args = []):
	if ProjectSettings.get_setting("escoria/debug/log_level") >= LOG_INFO:
		var argsstr = []
		if !args.empty():
			for arg in args:
				if arg is Array:
					for p in arg:
						argsstr.append(p.global_id)
				else:
					argsstr.append(str(arg))
		print("(I)\t" + string + " \t" + str(argsstr))


# Log a warning message
#
# #### Parameters
# 
# * string: Text to log
# * args: Additional information
func warning(string : String, args = []):
	if ProjectSettings.get_setting("escoria/debug/log_level") >= LOG_WARNING:
		var argsstr = str(args) if !args.empty() else ""
		printerr("(W)\t" + string + " \t" + argsstr)
		if ProjectSettings.get_setting("escoria/debug/terminate_on_warnings"):
			print_stack()
			assert(false)


# Log an error message
#
# #### Parameters
# 
# * string: Text to log
# * args: Additional information
func error(string : String, args = []):
	if ProjectSettings.get_setting("escoria/debug/log_level") >= LOG_ERROR:
		var argsstr = str(args) if !args.empty() else ""
		printerr("(E)\t" + string + " \t" + argsstr)
		if ProjectSettings.get_setting("escoria/debug/terminate_on_errors"):
			print_stack()
			assert(false)


# Log a warning message about an ESC file
#
# #### Parameters
# 
# * p_path: Path to the file
# * warnings: Array of warnings to put out
# * report_once: Additional messages about the same file will be ignored
func report_warnings(p_path : String, warnings : Array, report_once = false) -> void:
	var warning_is_reported = false
	if p_path == warning_path:
		warning_is_reported = true
		
	if !warning_is_reported:
		var text = "Warnings in file "+p_path+"\n"
		for w in warnings:
			if w is Array:
				text += str(w)+"\n"
			else:
				text += w+"\n"
		warning(text)
	
		if report_once:
			warning_is_reported = true


# Log an error message about an ESC file
#
# #### Parameters
# 
# * p_path: Path to the file
# * errors: Array of errors to put out
func report_errors(p_path : String, errors : Array) -> void:
	var text = "Errors in file "+p_path+"\n"
	for e in errors:
		if e is Array:
			text += str(e)+"\n"
		else:
			text += e+"\n"
	error(text)

