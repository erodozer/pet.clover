extends Label

func _process(_delta):
	var time = Time.get_time_dict_from_system() 
	
	text = "%02d %02d %s" % [
		(time.hour + 12) % 12,
		time.minute,
		"PM" if time.hour > 11 else "AM"
	]
