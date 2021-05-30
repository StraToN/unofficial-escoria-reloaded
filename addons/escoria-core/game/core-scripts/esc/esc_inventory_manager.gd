# A manager for inventory objects
extends Object
class_name ESCInventoryManager


# Check if the player has an inventory item
func inventory_has(p_obj) -> bool:
	return escoria.globals.globals.has("i/"+p_obj)


# Get all inventory items
func items_in_inventory() -> Array:
	var items = []
	for glob in escoria.globals.globals.keys():
		if glob.begins_with("i/") and escoria.globals.globals[glob]:
			items.append(glob.rsplit("i/", false)[0])
	return items
