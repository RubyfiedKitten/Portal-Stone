extends Node2D

var Pieces = load("res://Scenes/pieces.tscn")
const grid_offset = 15
const grid_size := 5
const cell_size : float = 100
var cells = {}
var p1Score = 0
var p2Score = 0
var selected_cell
var turn := 1
var direction : Vector2 = GlobalVariables.direction
var piece = []
var mouse_swapped := false

func _ready(): # Generates the grids
	piece.resize(grid_size)
	for k in 5:
		piece[k] = []
		piece[k].resize(grid_size)
	for x in grid_size:
		for y in grid_size:													 # Grid_cords : cell_cords
			var grid_cords = Vector2(x, y) # What I want is the dictionary to have (0, 0) : (75, 75)
			var cell_cord = Vector2(75+ x * (cell_size +  grid_offset), 75 + y * (cell_size + grid_offset))
			cells[grid_cords] = cell_cord
			piece[x][y] = null
	$ui/feedback2.text = "I serve as feedback :)"

func _process(_delta):
	$"ui/P1Score".text = "Player 1: " + str(p1Score)
	$"ui/P2Score".text = "Player 2: " + str(p2Score)
	selected_cell = get_cell()
	if Input.is_action_just_released("click"):
		mouse_swapped = false
		if selected_cell != null: # checks that i clicked on the grid
			var result = check_piece(selected_cell)
			if result[0]: # checks if there's a piece on that cell in the grid
				#for number in xorynumber(result[1]): 
				move_piece(selected_cell) # moves it if there is
			else:
				summon_piece(selected_cell)
		else:
			$ui/feedback.text = "That's not a valid placement location."

func check_piece(cell): # checks if there's an piece at cell.
	if piece[cell.x][cell.y] == null: #If there's nothing say no
		return [false, Vector2(cell)]
	else:
		return [true]

func get_cell(): # basically where the player clicks
	var mouse_pos = get_global_mouse_position()
	var cellCorner1
	var cellCorner2
	for cell in cells:
		cellCorner1 = cells[cell] + Vector2(50, 50)
		cellCorner2 = cells[cell] - Vector2(50, 50)
		if (cellCorner1.x > mouse_pos.x and mouse_pos.x > cellCorner2.x ):
			if (cellCorner1.y > mouse_pos.y and mouse_pos.y > cellCorner2.y ):
				if check_edge(cell):
					return cell # This is a valid cell where you can place pieces

func summon_piece(piece_location):
	var x = piece_location.x
	var y = piece_location.y
	piece[x][y] = Pieces.instantiate()
	if turn == 1:
		piece[x][y].modulate = "RED"
	elif turn == 2:
		piece[x][y].modulate = "GREEN"
	$"pieces storage".add_child(piece[x][y])
	piece[x][y].new_position = piece_location
	piece[x][y].global_position = cells[piece_location]
	turn = 3 - turn
	$ui/feedback.text = "It is player " + str(turn) + "'s turn."

func check_edge(cell): # will return true or false
	if (cell.x == 0 or cell.x == 4) or (cell.y == 0 or cell.y == 4):
		return true
	else:
		return false

func move_piece(cell):
	var next_cell = cell + direction
	var result = check_piece(next_cell)
	if !result[0]:
		piece[next_cell.x][next_cell.y] = piece[cell.x][cell.y]
		piece[next_cell.x][next_cell.y].global_position = cells[next_cell]
		piece[cell.x][cell.y] = null
	else:
		move_piece(next_cell)

func set_mouse(n):
	if n == "right":
		Input.set_custom_mouse_cursor(ResourceLoader.load("res://cursors/cursor right.png"))
		direction = Vector2(-1, 0)
	elif n == "left":
		Input.set_custom_mouse_cursor(ResourceLoader.load("res://cursors/cursor left.png"))
		direction = Vector2(1,0)
	elif n == "top":
		Input.set_custom_mouse_cursor(ResourceLoader.load("res://cursors/cursor down.png"))
		direction = Vector2(0, 1)
	elif n == "bottom":
		Input.set_custom_mouse_cursor(ResourceLoader.load("res://cursors/cursor up.png"))
		direction = Vector2(0,-1)
	elif n == "block":
		Input.set_custom_mouse_cursor(ResourceLoader.load("res://cursors/cursor block.png"))
		direction = Vector2(0,0)
	elif n == "default":
		Input.set_custom_mouse_cursor(ResourceLoader.load("res://cursors/cursor default.png"))
		direction = Vector2(0,0)

func _input(event):
	if Input.is_action_just_pressed("swap direction"):
		if not mouse_swapped:
			mouse_swapped = true
		else:
			mouse_swapped = false

	if event is InputEventMouseMotion:
		var cell_cords = get_cell()
		if cell_cords != null:
			if not mouse_swapped:
				if cell_cords.x == 0:
					set_mouse("left")
				elif cell_cords.x == 4:
					set_mouse("right")
				elif cell_cords.y == 0:
					set_mouse("top")
				elif cell_cords.y == 4:
					set_mouse("bottom")
			elif mouse_swapped:
				if cell_cords == Vector2(0, 0):
					set_mouse("top")
				elif cell_cords == Vector2(4, 0):
					set_mouse("top")
				elif cell_cords == Vector2(0, 4):
					set_mouse("bottom")
				elif cell_cords == Vector2(4, 4):
					set_mouse("bottom")
		else:
			if get_global_mouse_position().x > cells[Vector2(4,0)].x + 50:
				set_mouse("default") # This is off the board, so you'd expect the default mouse.
			else:
				set_mouse("block") # This is in the center of the board. You're not allowed to place pieces here.

func scoring():
	pass
	#don't have to check from the start of the game, only when the first 9 pieces have been played, check from then on. a boolean that's just a one time flip at the start of the game.
	#check for 5 in a row of the same color. 
	#remove those 5.
	# give the right player that point.

func win():
	if p1Score == 3:
		pass
	elif p2Score == 3:
		pass
