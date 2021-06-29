extends Control

signal back_button_pressed

export(PackedScene) var slot_ui_scene

func _ready():
	for i in escoria.save_data.get_saves_number():
		var new_slot = slot_ui_scene.instance()
		$ScrollContainer/slots.add_child(new_slot)
		new_slot.connect("pressed", self, "_on_slot_pressed", [i])

func _on_slot_pressed(slot_id : int) -> void:
	escoria.save_data.load_game(slot_id)

func _on_back_pressed():
	emit_signal("back_button_pressed")
