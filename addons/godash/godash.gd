"""
godash.gd
@author Nicholas Hydock <nhydock@gmail.com>
@description |>
	Collection of basic utilities that I find useful for game development
	that overcomes some of the missing features of gdscript
	
	Library and name inspired by lodash for javascript
"""

extends Reference

enum SELECT_CHOICE { KEY, VALUE }

static func rand_choice(collection, select=SELECT_CHOICE.VALUE, rand = null):
	"""
	Pick randomly out of a collection.
	"""
	if len(collection) == 0:
		return null
	if rand == null:
		rand = RandomNumberGenerator.new()
		rand.randomize()
	if typeof(collection) == TYPE_DICTIONARY:
		match select:
			SELECT_CHOICE.KEY:
				return collection.keys()[rand.randi() % collection.keys().size()]
			_:
				return collection.values()[rand.randi() % collection.values().size()]
	elif select is RandomNumberGenerator:
		rand = select
	var idx = rand.randi() % collection.size()
	return collection[idx]

static func rand_chance(collection: Dictionary, rand = null):
	"""
	Select a random key from a dictionary based on percentage chances
	defined for each key.
	"""
	
	var keys = []
	var values = []
	
	var total_weight = 0
	for key in collection.keys():
		var weight = collection[key]
		total_weight += weight
		keys.append(key)
		values.append(weight)
		
	var chance = (randf() if not rand else rand.randf()) * total_weight
	
	var total = 0
	for idx in range(len(values)):
		total += values[idx]
		if total >= chance:
			return keys[idx]
	return keys[-1]

static func extend(d1: Dictionary, d2: Dictionary) -> Dictionary:
	"""
	Creates a new dictionary that is the combination of 2 dictionaries
	Similar to object.assign in javascript
	"""
	var out = {}
	for k in d1.keys():
		out[k] = d1[k]
	for k in d2.keys():
		out[k] = d2[k]
	return out

static func enumerate_dir(resource_dir, ext = null) -> Array:
	"""
	Fetch a list of files in a directory that match the extension.
	
	Good for when you just want names without loading the actual file.
	"""
	var item_dir = Directory.new()
	var _items = []
	if item_dir.open(resource_dir) == OK:
		item_dir.list_dir_begin(true)
		var file_name = item_dir.get_next()
		while (file_name != ""):
			if (not ext) or (ext and file_name.ends_with(ext)):
				_items.append("%s%s" % [resource_dir, file_name])
			file_name = item_dir.get_next()
		item_dir.list_dir_end()
	else:
		printerr("can't load items: %s" % [resource_dir])
	return _items

static func load_dir(resource_dir, ext = '.tres', recurse = false) -> Dictionary:
	"""
	Load resource assets from a directory.
	Needed for various factories, such as for Items and Enemies
	
	This uses blocking io and is not suitable for large directories with lots of big files
	"""
	if ext is String:
		ext = [ext]
	var item_dir = Directory.new()
	var _items = {}
	if item_dir.open(resource_dir) == OK:
		item_dir.list_dir_begin(true)
		var file_name = item_dir.get_next()
		
		while (file_name != ""):
			if item_dir.current_is_dir() and recurse:
				var _sub_items = load_dir(resource_dir + "/" + file_name, ext, recurse)
				_items = extend(_items, _sub_items)
			else:
				for e in ext:
					if file_name.ends_with(e):
						var item = load(resource_dir + "/" + file_name)
						if item:
							_items[file_name] = item
							break
			file_name = item_dir.get_next()
		item_dir.list_dir_end()
	else:
		printerr("can't load items: %s" % [resource_dir])
	return _items

static func load_async(path):
	yield(Engine.get_main_loop(), "idle_frame")
	var loader = ResourceLoader.load_interactive(path)
	while loader.poll() == OK:
		yield(Engine.get_main_loop(), "idle_frame")
	
	assert(loader.poll() == ERR_FILE_EOF)
	return loader.get_resource()
	
