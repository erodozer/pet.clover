"""
SceneManager.gd
@description |>
	Simplify complex scene management with safe memory transitioning
	and dynamic loading of Node.  Scenes are the primary composition of a
	game's stateful context.  
	SceneManager introduces additional lifecycle hooks that are useful
	for Scenes that extend the functionality of Godot's own Node lifecycle.
	These new hooks are fully optional methods and allow for activity
	tied to when scenes load, unload, and transition into focus.
"""
extends Node

const godash = preload("res://addons/godash/godash.gd")
const LoadingScene = preload("./loading/scene.tscn")

onready var anim = $Transition/Fader/AnimationPlayer
onready var container = $Scene

var current_scene
var is_active = false

signal setup
signal started

func _notification(what: int) -> void:
	match what:
		MainLoop.NOTIFICATION_WM_FOCUS_OUT:
			Engine.target_fps = 10
		MainLoop.NOTIFICATION_WM_FOCUS_IN:
			# Disable the FPS cap
			Engine.target_fps = 0

func _ready():
	if container.get_child_count() == 0:
		# force wait until current scene is ready
		yield(get_tree(), "idle_frame")
		var s = get_tree().current_scene
		if s.is_in_group("scene"):
			s.get_parent().remove_child(s)
			change_scene(s)
	else:
		change_scene(container.get_child(0))

func change_scene(next_scene, params=[]):
	"""
	Changes scene with a transition.
	You can hold the fade back in transition if desired until
	the next scene is in a state that is considered ready
	"""
	get_tree().paused = true
	is_active = true
	
	anim.play("Fade")
	yield(anim, "animation_finished")
	
	var scene = current_scene
	if scene != null:
		if scene.has_method("_teardown"):
			var state = scene._teardown()
			if state and state is GDScriptFunctionState:
				yield(state, "completed")
		yield(get_tree(), "idle_frame")
		scene.queue_free()
		yield(scene, "tree_exited")
	
	if next_scene is String:
		"""
		if a scene node is passed through, like with debugging,
		we only need to fade in.  Else we're loading the scene
		"""
		if next_scene == "loading":
			current_scene = LoadingScene.instance()
		else:
			next_scene = next_scene \
				if next_scene.begins_with("res://") \
				else "res://scenes/%s/scene.tscn" % next_scene
			var res = yield(godash.load_async(next_scene), "completed")
			current_scene = res.instance()
	elif next_scene is Node:
		current_scene = next_scene
	else:
		current_scene = next_scene.instance()
		
	container.add_child(current_scene)
		
	if current_scene.has_method("_setup"):
		var state = current_scene._setup(params)
		if state and state is GDScriptFunctionState:
			yield(state, "completed")
	emit_signal("setup")
	
	yield(get_tree().create_timer(0.3), "timeout") 
	anim.play_backwards("Fade")
	yield(anim, "animation_finished")
	
	get_tree().paused = false
	
	if current_scene.has_method("_start"):
		var state = current_scene._start()
		if state and state is GDScriptFunctionState:
			yield(state, "completed")
	emit_signal("started")
	
	is_active = false
