extends Resource
class_name ShopResource

@export var flag: String
@export var display_name: String
@export var description: String
@export_range(0, 99999) var cost: int = 1
