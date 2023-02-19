extends Button

onready var minute_hand = get_node("%Minute")
onready var hour_hand = get_node("%Hour")
onready var second_hand = get_node("%Second")

func _process(delta):
	var time = Time.get_time_dict_from_system() 
	
#	hour_hand.rotation_degrees = lerp(0, 360, inverse_lerp(0, 12, time.hour))
#	minute_hand.rotation_degrees = lerp(0, 360, inverse_lerp(0, 60, time.minute))
#	second_hand.rotation_degrees = lerp(0, 360, inverse_lerp(0, 60, time.second))

	# pixel locked rotation
	hour_hand.rotation_degrees = stepify(lerp(0, 360, inverse_lerp(0, 12, time.hour)), 30)
	minute_hand.rotation_degrees = stepify(lerp(0, 360, inverse_lerp(0, 60, time.minute)), 30)
	second_hand.rotation_degrees = stepify(lerp(0, 360, inverse_lerp(0, 60, time.second)), 30)
	
