extends Node

@onready var fox = get_node("%Fox")
@onready var ball = get_node("%Ball")

const BALLS_TOTAL = 3
const MOVE_SPEED = 80

var balls_left = BALLS_TOTAL
var balls_caught = 0

func _ready():
	spawn_ball()

func _process(delta):
	var move: Vector2 = Vector2.ZERO
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var width = get_viewport().get_visible_rect().size.x
		var mouse_pos = get_viewport().get_mouse_position().x
		if mouse_pos < fox.position.x - 2 and fox.position.x > 6:
			move.x = -1
		elif mouse_pos > fox.position.x + 2 and fox.position.x < width - 6:
			move.x = 1
	else:
		move = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	fox.position.x += move.x * delta * MOVE_SPEED
	if move.x != 0:
		fox.scale.x = -sign(move.x)
			
func game_finished():
	await get_tree().create_timer(3.0).timeout
	
	var score = clamp(inverse_lerp(0, BALLS_TOTAL, balls_caught) * 100.0, 20, 100)
	
	# perfect score bonus
	if balls_caught == BALLS_TOTAL:
		score = 200
	
	NoClick.show()
	%Results/%Currency.text = "+%d" % [score * 10]
	%Results/%Happiness.text = "%d" % [score]
	%Results/%AnimationPlayer.play("show")
	await %Results/%AnimationPlayer.animation_finished
	NoClick.hide()
	
	GameState.stats = {
		# boredom goes down relative to speed of success
		"boredom": GameState.stats.boredom - score,
		# also grand bonus Honey as a prize
		"honey": GameState.stats.honey + score * 10,
	}
	GameState.timers = {
		GameState.GameActions.Play: GameState.now() + 300, # 5 minutes
	}
	
	SceneManager.change_scene("home")

func spawn_ball():
	balls_left -= 1
	if balls_left < 0:
		game_finished()
		ball.queue_free()
		return
		
	remove_child(ball)
	ball.sleeping = true
	await get_tree().physics_frame
	get_node("%BallCount").text = "%02d" % balls_left
	ball.linear_velocity = Vector2(0,0)
	ball.position = Vector2(randf_range(20, 140), randf_range(-50, -90))
	await get_tree().create_timer(1.0).timeout
	ball.sleeping = false
	add_child(ball)
	
func _on_BucketCatch_body_entered(body):
	balls_caught += 1
	get_node("%CatchCount").text = "%02d" % balls_caught
	spawn_ball()

func _on_FloorCatch_body_entered(body):
	spawn_ball()
