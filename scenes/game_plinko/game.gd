extends Node

onready var fox = get_node("%Fox")
onready var ball = get_node("%Ball")

const BALLS_TOTAL = 3

var balls_left = BALLS_TOTAL
var balls_caught = 0

func _ready():
	spawn_ball()

func _process(delta):
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		var mouse_pos = get_viewport().get_mouse_position().x
		if mouse_pos < fox.position.x - 2 and fox.position.x > 20:
			fox.position.x -= 40 * delta
			fox.scale.x = 1
		elif mouse_pos > fox.position.x + 2 and fox.position.x < 140:
			fox.position.x += 40 * delta
			fox.scale.x = -1
			
		if fox.animation != "walk":
			fox.play("walk")
			fox.get_node("Bucket/Sprite").play("walk")
			
	elif fox.animation != "idle":
		fox.play("idle")
		fox.get_node("Bucket/Sprite").play("idle")

func game_finished():
	yield(get_tree().create_timer(3.0), "timeout")
	
	var score = clamp(inverse_lerp(0, BALLS_TOTAL, balls_caught) * 100.0, 20, 100)
	
	# perfect score bonus
	if balls_caught == BALLS_TOTAL:
		score = 200
	
	GameState.stats = {
		# boredom goes down relative to speed of success
		"boredom": GameState.stats.boredom - score,
		# also grand bonus Honey as a prize
		"honey": GameState.stats.honey + score * 10,
	}
	GameState.timers = {
		"play": GameState.now() + 300, # 5 minutes
	}
	
	SceneManager.change_scene("flowershop")

func spawn_ball():
	balls_left -= 1
	if balls_left < 0:
		game_finished()
		return
		
	remove_child(ball)
	ball.sleeping = true
	yield(get_tree(), "physics_frame")
	get_node("%BallCount").text = "%02d" % balls_left
	ball.linear_velocity = Vector2(0,0)
	ball.position = Vector2(rand_range(20, 140), rand_range(-50, -90))
	yield(get_tree().create_timer(1.0), "timeout")
	ball.sleeping = false
	add_child(ball)
	
func _on_BucketCatch_body_entered(body):
	balls_caught += 1
	get_node("%CatchCount").text = "%02d" % balls_caught
	spawn_ball()

func _on_FloorCatch_body_entered(body):
	spawn_ball()
