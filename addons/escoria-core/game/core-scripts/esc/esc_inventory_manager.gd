# A manager for inventory objects
extends Object
class_name ESCInventoryManager


# Check if the player has an inventory item
#
# #### Parameters
#
# - p_obj: Inventory item
# **Returns** Wether the player has the inventory
func inventory_has(p_obj) -> bool:
	return escoria.globals_manager.has("i/%s" % p_obj)


# Get all inventory items
# **Returns** The items in the inventory
func items_in_inventory() -> Array:
	var items = []
	var filtered = escoria.globals_manager.filter("i/*")
	for glob in filtered.keys():
		if filtered[glob]:
			items.append(glob.rsplit("i/", false)[0])
	return items
