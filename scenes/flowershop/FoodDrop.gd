extends AnimatedSprite

const FOODS = {
	"nuggie": {
		"hungry": 50.0,
		"cooldown": 30.0,
	},
	"fries": {
		"hungry": 150.0,
		"cooldown": 40.0
	},
	"soju": {
		"hungry": 25.0,
		"boredom": -25.0,
		"cooldown": 20.0
	}
}

export var food_type = "nuggie"

var left_bound
var right_bound

func drop():
	var tween = create_tween()
	play("%s" % food_type)
	material.set_shader_param("width", 1)

	var next_pos = rand_range(left_bound, right_bound)
	
	tween.tween_property(self, "position", Vector2(next_pos, 62), 2.0)\
		.from(Vector2(next_pos, -24))\
		.set_trans(Tween.TRANS_LINEAR)
	
	yield(tween, "finished")
	
func eat():
	material.set_shader_param("width", 0)
	play("%s:eat" % food_type)
	
	yield(self, "animation_finished")
	position = Vector2(-1000, -1000)

	GameState.stats = {
		"hungry": GameState.stats.hungry + FOODS[food_type].get("hungry", 0.0),
		"boredom": GameState.stats.boredom + FOODS[food_type].get("boredom", 0.0),
	}
	GameState.timers = {
		"eat": GameState.now() + FOODS[food_type].get("cooldown", 0.0)
	}

