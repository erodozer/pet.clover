extends Node

const overrides = [".png", ".tscn", ".tres", ".json", ".res"]
var _theme_files = []

func _enter_tree():
	var theme = ProjectSettings.get_setting_with_override("application/config/theme")
	print(theme)
	
	var gdsh = preload("res://addons/godash/godash.gd")
	
	for res in gdsh.load_dir("res://theme/%s" % theme, overrides, true).values():
		var path = "res://%s" % res.resource_path.substr(len("res://theme/%s/" % GameState.THEME))
		if ResourceLoader.exists(path):
			res.take_over_path(path)
			_theme_files.append(res)
	
func _exit_tree():
	_theme_files = []
	
