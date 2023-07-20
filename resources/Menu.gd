extends Resource
class_name ResourceMenu

var default: get = get_default
var unlocked: get = get_unlocked

func get_items():
	return []

func get_default():
	return get_items()[0]
	
func get_unlocked():
	var u = []
	for i in get_items():
		if i.unlock == null or GameState.unlocks.get(i.unlock.flag, false):
			u.append(i)
	return u
	
