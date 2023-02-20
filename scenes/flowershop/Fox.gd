extends Node2D

var left_bound
var right_bound

onready var sprite = get_node("Sprite")
onready var dirty = get_node("Dirty")

var tween: SceneTreeTween
var pause = false setget set_paused

var is_sick = false
var is_asleep = false
var next_action = 0

func _ready():
	GameState.connect("stats_changed", self, "_update_stats")
	
func _update_stats(stats):
	dirty.visible = false
	
	if stats.is_asleep and not is_asleep:
		_rest()
	elif stats.sick > 75.0 and not is_sick:
		_sick()
	elif stats.sick < 75.0 and is_sick:
		is_sick = false
		_wander()
	elif not stats.is_asleep and is_asleep:
		is_asleep = false
		_wander()
	if not is_asleep and not is_sick:
		dirty.visible = stats.dirty > 50.0

func set_paused(value = false):
	pause = value
	if value and tween:
		tween.kill()
		tween = null

func move_to(target: Vector2, padding = 0):
	# move clover over to the point on the floor
	if tween:
		tween.kill()
		
	tween = create_tween()
	
	var facing = sign(position.x - target.x)
	var destination = target.x + (padding * sign(facing))
	
	tween.tween_property(
		self, "position:x", destination, 2.0
	)
	
	var facing_dest = sign(position.x - destination)
	sprite.scale.x = facing_dest
	sprite.play("walk")
	
	# wait for clover to get to the food
	yield(tween, "finished")
	sprite.scale.x = facing
	sprite.play("idle")
	
func _wander():
	# move action
	var next = rand_range(left_bound, right_bound)
	
	yield(move_to(Vector2(next, 0.0)), "completed")
	
	next_action = GameState.now() + rand_range(2.0, 10.0)
	
func _rest():
	sprite.play("sleep")
	sprite.scale.x = 1.0
	is_asleep = true

func _sick():
	sprite.play("sick")
	sprite.scale.x = 1.0
	is_sick = true
	
func _process(_delta):
	if pause:
		return
	elif not is_inside_tree():
		return
	elif GameState.stats.is_asleep:
		return
	elif GameState.stats.sick > 75.0:
		return
	elif GameState.now() < next_action:
		return
	
	set_process(false)
	yield(_wander(), "completed")
	set_process(true)
