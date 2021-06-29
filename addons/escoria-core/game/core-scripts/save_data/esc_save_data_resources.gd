# Saves and loads savegame files
# Each node is responsible for finding itself in the save_game
# dict so saves don't rely on the nodes' path or their source file
extends Node

const SaveGame = preload( \
	"res://addons/escoria-core/game/core-scripts/save_data/esc_savegame.gd" \
)
const SaveSettings = preload( \
	"res://addons/escoria-core/game/core-scripts/save_data/esc_savesettings.gd"\
)
# TODO: Use project setting to save to res://debug vs user://
onready var SAVE_FOLDER: String = ProjectSettings \
	.get_setting("escoria/main/savegames_path")
var SAVE_NAME_TEMPLATE: String = "save_%03d.tres"

onready var SETTINGS_FOLDER: String = ProjectSettings \
	.get_setting("escoria/main/settings_path")
var SETTINGS_TEMPLATE: String = "settings.tres"


func get_saves_number() -> int:
	var saves : int = 0
	for i in range(5):
		var save_file_path: String = SAVE_FOLDER.plus_file(SAVE_NAME_TEMPLATE % i)
		var file: File = File.new()
		if file.file_exists(save_file_path):
			saves += 1
	return saves


func save_game(id: int):
	# Passes a SaveGame resource to all nodes to save data from
	# and writes it to the disk
	var save_game := SaveGame.new()
	save_game.game_version = ProjectSettings.get_setting(
		"escoria/main/game_version"
	)
	save_game.name = "blah"
	
	var datetime = OS.get_datetime()
	var datetime_string = "%s/%s/%s %s:%s" % [
		datetime["day"],
		datetime["month"],
		datetime["year"],
		datetime["hour"],
		datetime["minute"],
	]
	save_game.date = datetime_string
	
#	escoria.event_manager.save(save_game)
	escoria.globals_manager.save_game(save_game)
	escoria.object_manager.save_game(save_game)
	escoria.main.save_game(save_game)
#	escoria.command_registry.save(save_game)
#	escoria.resource_cache.save(save_game)

	var directory: Directory = Directory.new()
	if not directory.dir_exists(SAVE_FOLDER):
		directory.make_dir_recursive(SAVE_FOLDER)

	var save_path = SAVE_FOLDER.plus_file(SAVE_NAME_TEMPLATE % id)
	escoria.logger.debug("Attempting to save game. Content of savegame data:")
	escoria.logger.debug(str(save_game.data))
	var error: int = ResourceSaver.save(save_path, save_game)
	if error != OK:
		escoria.logger.report_errors(
			"esc_save_data_resources.gd",
			["There was an issue writing the save %s to %s" % [id, save_path]])


func load_game(id: int):
	# Reads a saved game from the disk and delegates loading
	# to the individual nodes to load
	var save_file_path: String = SAVE_FOLDER.plus_file(SAVE_NAME_TEMPLATE % id)
	var file: File = File.new()
	if not file.file_exists(save_file_path):
		escoria.logger.report_errors(
			"esc_save_data_resources.gd",
			["Save file %s doesn't exist" % save_file_path])
		return

	var save_game: Resource = load(save_file_path)
#	escoria.inventory_manager.load(save_game)
#	escoria.action_manager.load(save_game)
#	escoria.event_manager.load(save_game)
#	escoria.main.load_game(save_game)
#	escoria.globals_manager.load_game(save_game)
#	escoria.object_manager.load_game(save_game)
#	escoria.command_registry.load(save_game)
#	escoria.resource_cache.load(save_game)

	var load_event = ESCEvent.new(":load")
	var load_statements = [
#		ESCCommand.new("cut_scene telon fade_out"),
		ESCCommand.new("change_scene %s false" \
			% save_game.data["main"]["current_scene_filename"]),
	]
	
	## GLOBALS
	for k in save_game.data["globals"].keys():
		load_statements.append(
			ESCCommand.new("set_global %s \"%s\"\n" \
				% [k, save_game.data["globals"][k]])
		)
	
	## OBJECTS
	for object_global_id in save_game.data["objects"].keys():
		load_statements.append(ESCCommand.new("set_active %s %s" \
			% [object_global_id, save_game.data["objects"][object_global_id]["active"]]))
		load_statements.append(ESCCommand.new("set_interactive %s %s" \
			% [object_global_id,save_game.data["objects"][object_global_id]["interactive"]]))
		load_statements.append(ESCCommand.new("set_state %s %s true" \
			% [object_global_id,save_game.data["objects"][object_global_id]["state"]]))
			
		if save_game.data["objects"][object_global_id].has("global_transform"):
			load_statements.append(ESCCommand.new("teleport_pos %s %s %s" \
				% [object_global_id, 
				save_game.data["objects"][object_global_id]["global_transform"].origin.x,
				save_game.data["objects"][object_global_id]["global_transform"].origin.y]))
				
			var angle = int(save_game.data["objects"][object_global_id]["last_deg"])
			load_statements.append(ESCCommand.new("set_angle %s %s" \
				% [object_global_id, save_game.data["objects"][object_global_id]["last_deg"]]))
	
	
	load_event.statements = load_statements
	escoria.event_manager.queue_event(load_event)
	
	
	
	
	

func save_settings():
	var settings_res := SaveSettings.new()
	settings_res.game_version = ProjectSettings.get_setting(
		"escoria/main/game_version"
	)
	settings_res.settings = escoria.settings
	
	var directory: Directory = Directory.new()
	if not directory.dir_exists(SETTINGS_FOLDER):
		directory.make_dir_recursive(SETTINGS_FOLDER)

	var save_path = SETTINGS_FOLDER.plus_file(SETTINGS_TEMPLATE)
	var error: int = ResourceSaver.save(save_path, settings_res)
	if error != OK:
		escoria.logger.report_errors(
			"esc_save_data_resources.gd:save_settings()",
			["There was an issue writing settings %s" % save_path])


func load_settings():
	var save_settings_path: String = SETTINGS_FOLDER.plus_file(SETTINGS_TEMPLATE)
	var file: File = File.new()
	if not file.file_exists(save_settings_path):
		escoria.logger.report_warnings(
			"esc_save_data_resources.gd:load_settings()",
			["Settings file %s doesn't exist" % save_settings_path,
			"Setting default settings."])
		save_settings()
		return

	var settings_file: Resource = load(save_settings_path)
	escoria.apply_settings(settings_file.settings)
