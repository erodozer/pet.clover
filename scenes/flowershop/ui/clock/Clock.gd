extends Button

onready var minute_hand = get_node("%Minute")
onready var hour_hand = get_node("%Hour")

func _ready():
	_update_time()

func _update_time():
	var time = Time.get_time_dict_from_system() 
	
	# kill me, this is the dumbest way to draw a clock
	# but I'm doing it because I want it to look good with sprites
	# at a low resolution
	
	if time.hour % 3 in [1, 2]:
		hour_hand.texture = preload("./h_1.png")
	elif time.hour % 6 == 3:
		hour_hand.texture = preload("./h_2.png")
	else:
		hour_hand.texture = preload("./h_0.png")
	
	if time.minute % 15 > 7:
		minute_hand.texture = preload("./m_1.png")	
	elif time.minute % 30 >= 15:
		minute_hand.texture = preload("./m_2.png")
	else:
		minute_hand.texture = preload("./m_0.png")
			
	minute_hand.flip_h = time.minute >= 30
	minute_hand.flip_v = time.minute >= 15 && time.minute <= 45
	
	hour_hand.flip_h = (time.hour % 12) >= 6
	hour_hand.flip_v = (time.hour % 12) >= 3 && (time.hour % 12) <= 9

func _process(_delta):
	_update_time()
