extends Button

@onready var minute_hand = get_node("%Minute")
@onready var hour_hand = get_node("%Hour")

func _ready():
	_update_time()

func _update_time():
	var time = Time.get_time_dict_from_system()
	
	hour_hand.frame = wrapi(
		lerp(
			0, hour_hand.vframes,
			((time.hour * 60.0 + time.minute) / (60.0 * 12.0))
		),
		0, hour_hand.vframes
	)
	minute_hand.frame = lerp(0, minute_hand.vframes, time.minute / 60.0)
	
func _process(_delta):
	_update_time()
