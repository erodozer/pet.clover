"""
AppSkin

@author Erodozer <ero@erodozer.moe>
@description |>
	Utility for easily applying "skins" to a Godot application.
	This is a stopgap solution until Godot supports things like multiple filesystem
	location Resource Loading with fallback.  It is also to help ease "mod" like
	development that focuses on exact filepath replacement, which can be a bit 
	unweildy to do within Godot's editor.
	
	The largest downside to this library is the fact that Godot's resource loader
	will uncache a resource when there are no more references.  For games that
	are normally aggressive about memory management, this can cause the skin to
	be unloaded and the application will revert to its original files.
	
	To resolve this, this library holds the references of all resources loaded
	in memory.  If you have a lot of resources being skinned and the resources
	are quite large, particularly assets, this can bloat the memory usage
	a bit.  If you do not wish to keep things in memory, you can disable the 
	forced theme caching and just remember to reload the assets regularly.
"""
extends Node
class_name AppSkin

const GROUP_NAME = "app_skin"

static func instance():
	return Engine.get_main_loop().get_first_node_in_group(GROUP_NAME)
	
static func loaded():
	while instance() == null:
		await Engine.get_main_loop().process_frame
	
	if instance().loading:
		await instance().theme_applied

@export var hold_cache = true
const overrides = [".png", ".tscn", ".tres", ".json", ".res"]
var _theme_files = []

signal theme_applied
var loading = true

func _ready():
	add_to_group(GROUP_NAME)
	apply("ham")
	
func apply(theme = ProjectSettings.get_setting_with_override("application/config/theme")):
	loading = true
	
	var gdsh = preload("res://addons/godash/godash.gd")
	
	# overlays active theme contents onto the game's resources
	# unfortunately 
	for res in gdsh.load_dir("res://theme/%s" % theme, overrides, true).values():
		print("found: " + res.resource_path)
		var path = "res://%s" % res.resource_path.substr(len("res://theme/%s/" % GameState.THEME))
		if ResourceLoader.exists(path):
			res.take_over_path(path)
			if hold_cache:
				_theme_files.append(res)
			
	loading = false
	theme_applied.emit()
	
func _exit_tree():
	_theme_files = []
	
