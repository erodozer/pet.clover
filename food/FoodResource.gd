extends Resource
class_name FoodResource

@export_range(0, 999) var hungry = 0.0
@export_range(-100, 100) var boredom = 0.0
@export_range(0.1, 100.0) var cooldown = 1.0
@export var unlock: String = ""
@export var icon: Texture2D
@export var animation: SpriteFrames
