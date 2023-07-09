extends Node2D

var left_bound
var right_bound

@onready var sprite = get_node("Sprite2D")
@onready var dirty = get_node("Dirty")

var tween: Tween
var pause = false: set = set_paused

var next_action = 0

func _ready():
	GameState.connect("stats_changed", Callable(self, "_update_stats"))
	(get_node("FollowCamera") as Camera2D).make_current()
	
func _update_stats(stats):
	dirty.visible = false
	
	if stats.is_asleep:
		_rest()
	elif stats.sick > 75.0:
		_sick()
	else:
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
	await tween.finished
	sprite.scale.x = facing
	sprite.play("idle")
	
func _wander():
	# move action
	var next = randf_range(left_bound, right_bound)
	
	next_action = GameState.now() + randf_range(2.0, 10.0)
	move_to(Vector2(next, 0.0))
	
func _rest():
	if pause:
		return
	sprite.play("sleep")
	sprite.scale.x = 1.0

func _sick():
	if pause:
		return
	sprite.play("sick")
	sprite.scale.x = 1.0
	
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
	
	_wander()
