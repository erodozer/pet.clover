# simple integrations with twitch chat when running in HTML5 mode
extends Node

signal chat_command(action)

var eventBus
var _cb

# Called when the node enters the scene tree for the first time.
func _ready():
	if not OS.has_feature('JavaScript'):
		return
	
	var _js_doc = JavaScript.get_interface("document")
	var _js_win = _js_doc.defaultView
	
	eventBus = _js_win.GODOT_BRIDGE
	_cb = JavaScript.create_callback(self, "handle_chat_action")
	eventBus.listen(_cb)
	
func handle_chat_action(args):
	var command = args[0]
	emit_signal("chat_command", command)
