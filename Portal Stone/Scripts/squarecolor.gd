extends ColorRect

@onready var square = $"."
@onready var color_rect_2 = $ColorRect2
@export var selectable :bool = false
@export var cords : Vector2
@export var occupied : bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	color_rect_2.color = square.color
