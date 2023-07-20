extends Node

signal selected(choice)

@onready var clock = %Timer
@onready var time_label = %TimeLeft
@onready var btn_group = ButtonGroup.new()

var correct = 0
var incorrect = 0

func _start():
	$AnimationPlayer.play("Show")
	await $AnimationPlayer.animation_finished
	
	generate_question()
	
	clock.timeout.connect(game_finished)
	
	for btn in %Answers.get_children():
		(btn as Button).button_group = btn_group
		
	btn_group.pressed.connect(_on_button_pressed)
	
func game_finished():
	var honey = 100 * correct
	var boredom = (10 * correct) - (5 * incorrect)
	
	NoClick.show()
	%Results/%Currency.text = "+%d" % [honey]
	%Results/%Happiness.text = "%d" % [boredom]
	%Results/%AnimationPlayer.play("show")
	await %Results/%AnimationPlayer.animation_finished
	NoClick.hide()
	
	GameState.stats = {
		# boredom goes down relative to correct / incorrect
		"boredom": GameState.stats.boredom - boredom,
		# also grant bonus Honey as a prize
		"honey": GameState.stats.honey + honey,
	}
	GameState.timers = {
		"play": GameState.now() + 240, # 4 minutes
	}
	
	SceneManager.change_scene("home")

func generate_question():
	NoClick.show()
	var tween = create_tween()
	
	clock.paused = false
	
	var valid_ops = []
	var valid_values = []
	var x = 0
	var y = 0
	
	while len(valid_ops) == 0:
		valid_ops = []
		valid_values = []
		x = randi_range(1, 99)
		y = randi_range(1, 99)
		
		if x * y <= 99:
			valid_ops.append("*")
			valid_values.append(x * y)
		if x % y == 0:
			valid_ops.append("/")
			valid_values.append(x / y)
		if x - y > 1:
			valid_ops.append("-")
			valid_values.append(x - y)
		if x + y <= 99:
			valid_ops.append("+")
			valid_values.append(x + y)
	
	var i = randi() % len(valid_ops)
	var op = valid_ops[i]
	var z = valid_values[i]
	
	var answer
	var answers = []
	match randi_range(1, 3):
		1:
			%Question.text = "_ %s %d = %d" % [op, y, z]
			answer = x
		2:
			%Question.text = "%d %s _ = %d" % [x, op, z]
			answer = y
		3:
			%Question.text = "%d %s %d = _" % [x, op, y]
			answer = z
		
	answers.append(answer)
	while len(answers) < 4:
		var b = randi_range(1, 99)
		if b == answer:
			continue
			
		answers.append(b)
		
	answers.shuffle()
	
	for idx in range(len(answers)):
		var choice = answers[idx]
		var btn = %Answers.get_child(idx)
		btn.set_meta("answer", choice)
		btn.modulate = Color.WHITE
		btn.text = "%d" % choice
		
	%Question.visible_ratio = 0.0
	tween.tween_property(%Question, "visible_ratio", 1.0, 0.5)
	
	await tween.finished
	clock.paused = false
	if clock.is_stopped():
		clock.start(30)
	NoClick.hide()
		
	var user_answer = await selected
	
	NoClick.show()
	clock.paused = true
	if user_answer != answer:
		btn_group.get_pressed_button().modulate = Color.RED
		btn_group.get_pressed_button().button_pressed = false
		incorrect += 1
		%Pet.play("study:incorrect")
		%Teacher.play("incorrect")
		await %Teacher.animation_finished
		%Pet.play("study")
		%Teacher.play("default")
		if clock.time_left - 3.0 > 0:
			clock.start(clock.time_left - 3.0)
		else:
			game_finished()
			return
	else:
		btn_group.get_pressed_button().modulate = Color.GREEN
		btn_group.get_pressed_button().button_pressed = false
		correct += 1
		%Pet.play("study:correct")
		%Teacher.play("correct")
		await %Teacher.animation_finished
		%Pet.play("study")
		%Teacher.play("default")
	clock.paused = false
	NoClick.hide()
		
	call_deferred("generate_question")
	
func _on_button_pressed(option):
	selected.emit(option.get_meta("answer"))

func _process(_delta):
	time_label.text = "T-%02d" % [int(clock.time_left)]
