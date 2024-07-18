extends Container

const SQUARE = preload("res://Scenes/square.tscn")
var gridsize = 5
var board_data = {}

func generate_grid():
	for y in gridsize:
		for x in gridsize:
			var board = SQUARE.instantiate()
			board.position = Vector2(x, y)
			board_data = board

func select_tile():
	var mouse_pos = get_viewport().get_mouse_position()
	if mouse_pos == board_data.board_pos and board_data.selectable:
		return board_data.position

func _ready():
	generate_grid()
