extends Control


func _test_basic() -> bool:
	var esc = """
:test
# first group
>
	say player "Test"
	# Second group
	> 	[test]
		say player "Test2 BLANK"
	say player "Test3" [test2]
	# Third group
	>
		say player "Test4"
# Fourth group
>
	say player "Test5"
	"""
	var script = escoria.esc_compiler.compile(esc.split("\n"))
	
	var subject = script
	assert(subject is ESCScript)
	
	subject = script.events.keys()
	assert(subject.size() == 1)
	assert(subject[0] == "test")
	
	subject = script.events["test"].commands
	assert(subject.size() == 2)
	
	subject = script.events["test"].commands[0]
	assert(subject is ESCGroup)
	assert(subject.commands.size() == 4)
	
	subject = script.events["test"].commands[0].commands[0]
	assert(subject is ESCCommand)
	assert(subject.name == "say")
	assert(subject.parameters.size() == 2)
	assert(subject.parameters[0] == "player")
	assert(subject.parameters[1] == "Test")
	
	subject = script.events["test"].commands[0].commands[1]
	assert(subject is ESCGroup)
	assert(subject.conditions.size() == 1)
	assert(subject.conditions[0] is ESCCondition)
	assert(subject.conditions[0].flag == "test")
	
	subject = script.events["test"].commands[0].commands[1].commands[0]
	assert(subject is ESCCommand)
	assert(subject.name == "say")
	assert(subject.parameters.size() == 2)
	assert(subject.parameters[0] == "player")
	assert(subject.parameters[1] == "Test2 BLANK")
	
	subject = script.events["test"].commands[0].commands[2]
	assert(subject is ESCCommand)
	assert(subject.name == "say")
	assert(subject.parameters.size() == 2)
	assert(subject.parameters[0] == "player")
	assert(subject.parameters[1] == "Test3")
	assert(subject.conditions.size() == 1)
	assert(subject.conditions[0].flag == "test2")
	
	subject = script.events["test"].commands[0].commands[3]
	assert(subject is ESCGroup)
	assert(subject.commands.size() == 1)
	
	subject = script.events["test"].commands[1]
	assert(subject is ESCGroup)
	assert(subject.commands.size() == 1)
	
	return true
	

func _test_conditions() -> bool:
	var esc = """
:test
say player "Test" [flag]
say player "Test" [flag1,flag2]
say player "Test" [!flag]
say player "Test" [i/flag]
say player "Test" [i/flag,flag]
say player "Test" [i/flag,flag,!flag2]
say player "Test" [eq flag 3]
say player "Test" [eq flag 3,gt flag 5]
say player "Test" [!eq flag 3]
	"""
	var script = escoria.esc_compiler.compile(esc.split("\n"))
	
	var subject = script.events["test"].commands[0]
	assert(subject is ESCCommand)
	assert(subject.conditions.size() == 1)
	
	subject = script.events["test"].commands[0].conditions[0]
	assert(subject.flag == "flag")
	assert(not subject.negated)
	assert(not subject.inventory)
	assert(subject.comparison == ESCCondition.COMPARISON_NONE)
	
	subject = script.events["test"].commands[1].conditions
	assert(subject.size() == 2)
	assert(subject[0].flag == "flag1")
	assert(subject[1].flag == "flag2")
	
	subject = script.events["test"].commands[2].conditions
	assert(subject.size() == 1)
	assert(subject[0].flag == "flag")
	assert(subject[0].negated)
	
	subject = script.events["test"].commands[3].conditions
	assert(subject.size() == 1)
	assert(subject[0].flag == "flag")
	assert(subject[0].inventory)
	
	subject = script.events["test"].commands[4].conditions
	assert(subject.size() == 2)
	assert(subject[0].flag == "flag")
	assert(subject[0].inventory)
	assert(subject[1].flag == "flag")
	assert(not subject[1].inventory)
	
	subject = script.events["test"].commands[5].conditions
	assert(subject.size() == 3)
	assert(subject[0].flag == "flag")
	assert(subject[0].inventory)
	assert(subject[1].flag == "flag")
	assert(not subject[1].inventory)
	assert(subject[2].flag == "flag2")
	assert(not subject[2].inventory)
	assert(subject[2].negated)
	
	subject = script.events["test"].commands[6].conditions
	assert(subject.size() == 1)
	assert(subject[0].flag == "flag")
	assert(subject[0].comparison == ESCCondition.COMPARISON_EQ)
	assert(subject[0].comparison_value == 3)
	
	subject = script.events["test"].commands[7].conditions
	assert(subject.size() == 2)
	assert(subject[0].flag == "flag")
	assert(subject[0].comparison == ESCCondition.COMPARISON_EQ)
	assert(subject[0].comparison_value == 3)
	assert(subject[1].flag == "flag")
	assert(subject[1].comparison == ESCCondition.COMPARISON_GT)
	assert(subject[1].comparison_value == 5)
	
	subject = script.events["test"].commands[8].conditions
	assert(subject.size() == 1)
	assert(subject[0].flag == "flag")
	assert(subject[0].comparison == ESCCondition.COMPARISON_EQ)
	assert(subject[0].comparison_value == 3)
	assert(subject[0].negated)
	
	return true


func _test_event_flags() -> bool:
	var esc = """
:test | TK
:test2 | TK NO_TT
:test3 | TK NO_TT NO_HUD
:test4 | TK NO_TT CUT_BLACK
	"""
	var script = escoria.esc_compiler.compile(esc.split("\n"))
	
	var subject = script.events
	assert(subject.keys().size() == 4)
	assert("test" in subject.keys())
	assert("test2" in subject.keys())
	assert("test3" in subject.keys())
	assert("test4" in subject.keys())
	
	subject = script.events["test"]
	assert(subject.name == "test")
	assert(subject.flags & ESCEvent.FLAG_TK != 0)
	assert(subject.flags & ESCEvent.FLAG_NO_TT == 0)
	
	subject = script.events["test2"]
	assert(subject.name == "test2")
	assert(subject.flags & ESCEvent.FLAG_TK != 0)
	assert(subject.flags & ESCEvent.FLAG_NO_TT != 0)
	
	subject = script.events["test3"]
	assert(subject.name == "test3")
	assert(subject.flags & ESCEvent.FLAG_TK != 0)
	assert(subject.flags & ESCEvent.FLAG_NO_TT != 0)
	assert(subject.flags & ESCEvent.FLAG_NO_HUD != 0)
		
	subject = script.events["test4"]
	assert(subject.name == "test4")
	assert(subject.flags & ESCEvent.FLAG_TK != 0)
	assert(subject.flags & ESCEvent.FLAG_NO_TT != 0)
	assert(subject.flags & ESCEvent.FLAG_NO_HUD == 0)
	assert(subject.flags & ESCEvent.FLAG_CUT_BLACK != 0)
	return true
	

func _test_dialog() -> bool:
	var esc = """
:test
?
	- "Option 1"
		say player "test"
	- "Option 2" [flag]
		say player "test2"
	- "Option 3"
		>
			say player "test3"
!
	"""
	var script = escoria.esc_compiler.compile(esc.split("\n"))
	
	var subject = script.events["test"].commands
	assert(subject.size() == 1)

	assert(subject[0] is ESCDialog)
	assert(subject[0].options.size() == 3)
	
	subject = script.events["test"].commands[0].options[0]
	assert(subject is ESCDialogOption)
	assert(subject.option == "Option 1")
	
	subject = script.events["test"].commands[0].options[0].commands
	assert(subject.size() == 1)
	assert(subject[0] is ESCCommand)
	assert(subject[0].name == "say")
	assert(subject[0].parameters.size() == 2)
	
	subject = script.events["test"].commands[0].options[1]
	assert(subject is ESCDialogOption)
	assert(subject.option == "Option 2")
	assert(subject.conditions.size() == 1)
	assert(subject.conditions[0].flag == "flag")
	
	subject = script.events["test"].commands[0].options[1].commands
	assert(subject.size() == 1)
	assert(subject[0] is ESCCommand)
	assert(subject[0].name == "say")
	assert(subject[0].parameters.size() == 2)
	
	subject = script.events["test"].commands[0].options[2]
	assert(subject is ESCDialogOption)
	assert(subject.option == "Option 3")
	
	subject = script.events["test"].commands[0].options[2].commands
	assert(subject.size() == 1)
	assert(subject[0] is ESCGroup)
	assert(subject[0].commands.size() == 1)
	assert(subject[0].commands[0] is ESCCommand)
	assert(subject[0].commands[0].parameters.size() == 2)
	
	return true
	

func _on_BasicFunctionality_pressed():
	$VBoxContainer/VBoxContainer/BasicFunctionality.pressed = self._test_basic()


func _on_Conditions_pressed():
	$VBoxContainer/VBoxContainer/Conditions.pressed = self._test_conditions()


func _on_EventFlags_pressed():
	$VBoxContainer/VBoxContainer/EventFlags.pressed = self._test_event_flags()


func _on_Dialog_pressed():
	$VBoxContainer/VBoxContainer/Dialog.pressed = self._test_dialog()