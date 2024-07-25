extends Node2D

var red_piece = preload("res://Scenes/red_piece.tscn")
var green_piece = preload("res://Scenes/green_piece.tscn")
var row_sum = 0
var col_sum = 0
const grid_offset = 15
const grid_size := 5
const cell_size : float = 100
var cells = {}
var p1Score = 0
var p2Score = 0
var selected_cell
var turn := 1
var turn_count := 0
var direction : Vector2 
var grid_data = [] # grid_data
var count = 1
var pushed = 0
var mouse_swapped := false
#var turn_and_color = {1 : Color("RED"), 2 : Color("GREEN")}

func _ready(): # Generates the grids
	grid_data.resize(grid_size)
	for k in grid_size:
		grid_data[k] = []
		grid_data[k].resize(grid_size)
	for x in grid_size:
		for y in grid_size:													 # Grid_cords : cell_cords
			var grid_cords = Vector2(x, y) # What I want is the dictionary to have (0, 0) : (75, 75)
			var cell_cord = Vector2(75+ x * (cell_size +  grid_offset), 75 + y * (cell_size + grid_offset))
			cells[grid_cords] = cell_cord
			grid_data[x][y] = 0
	$ui/feedback2.text = "I serve as feedback :)"
#	summon_piece(Vector2(3,2))
#	summon_piece(Vector2(0,3))
#	summon_piece(Vector2(2,1))
#	summon_piece(Vector2(4,3))
#	summon_piece(Vector2(0,2))
#	summon_piece(Vector2(3,0))
#	summon_piece(Vector2(3,3))
#	summon_piece(Vector2(2,3))

func _process(_delta): # Main loop

	$"ui/P1Score".text = "Player 1: " + str(p1Score)
	$"ui/P2Score".text = "Player 2: " + str(p2Score)

	if Input.is_action_just_released("click"):
		selected_cell = get_cell()
		the_click_function()
		scoring()
		print(grid_data)

func check_next(cell): # check for gap
	cell = cell + direction * count
	if not (cell.x < 0 or cell.x > 4 or cell.y < 0 or cell.y > 4): # Checks if the grid_data is still on the board.
		var result = grid_data[cell.x][cell.y]
		if result != 0: 	# there's a grid_data, move along
			count += 1
			return false
		else: 				# GAP
			return true
	else: 					# else it's a pushed grid_data
		count -= 1
		cell = cell - direction
		pushed = grid_data[cell.x][cell.y]
		#last_pushed = pushed
		if turn_count < 2: # Checks if i'm not using a pushed grid_data.
			if pushed == turn: # If you push off your own grid_data:
				pushed = 0						# sdelete it
				turn_count += 1
				turn_change()
			else:
				#pushed = last_pushed
				turn_count = 1
				turn_change()
			grid_data[cell.x][cell.y].queue_free()
			grid_data[cell.x][cell.y] = 0
			return true
		else:
			$ui/feedback.text = "Can't push off with a pushed grid_data!"

func find_gap(cell):
	if grid_data[cell.x][cell.y] == 0:
		summon_piece(cell)
	else:
		while check_next(cell) == false:
			pass #This confuses me, idk why it works
		for n in count:
			move_piece(cell + (direction * (count - 1)))
			count -= 1
		summon_piece(cell)

func the_click_function():
	if selected_cell != null: # checks that i clicked on the grid
		find_gap(selected_cell)
	else:
		$ui/feedback.text = "That's not a valid placement location."

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
	if turn == 1:
		var red_piece = red_piece.instantiate()
		grid_data[x][y] = turn
		$"pieces storage".add_child(red_piece)
		red_piece.global_position = cells[piece_location]
		$ui/feedback.text = "It is player 2's turn."
	elif turn == -1:
		var green_piece = green_piece.instantiate()
		grid_data[x][y] = turn
		$"pieces storage".add_child(green_piece)
		green_piece.global_position = cells[piece_location]
		$ui/feedback.text = "It is player 1's turn."
	turn_change()
	

func turn_change():
	if turn_count > 1:
		turn_count -= 1
	else:
		turn *= -1

func check_edge(cell): # returns true or false
	if (cell.x == 0 or cell.x == 4) or (cell.y == 0 or cell.y == 4):
		return true
	else:
		return false

func move_piece(cell):
	var next_cell = cell + direction
	pushed = 0
	grid_data[next_cell.x][next_cell.y] = grid_data[cell.x][cell.y]
	grid_data[next_cell.x][next_cell.y].global_position = cells[next_cell]
	grid_data[cell.x][cell.y] = 0

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

func _input(event): #This just does the mouse, which detemines the direction.
	if Input.is_action_just_pressed("swap direction"):
		mouse_swapped = !mouse_swapped

	if event is InputEventMouseMotion:
		var cell_cords = get_cell()
		if cell_cords != null: # default directions
			if cell_cords.x == 0:
				set_mouse("left")
			elif cell_cords.x == 4:
				set_mouse("right")
			elif cell_cords.y == 0:
				set_mouse("top")
			elif cell_cords.y == 4:
				set_mouse("bottom")
			# checks corners
			if cell_cords == Vector2(0, 0) or cell_cords == Vector2(4, 0) or cell_cords == Vector2(0, 4) or  cell_cords == Vector2(4, 4):
				if not mouse_swapped:
					pass
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

func five_in_a_row():
	for i in grid_size:
		row_sum = grid_data[i][0] + grid_data[i][1] + grid_data[i][2] + grid_data[i][3] + grid_data[i][4]
		col_sum = grid_data[0][i] + grid_data[1][i] + grid_data[2][i] + grid_data[3][i] + grid_data[4][i]

		if row_sum == 5:
			p1Score += 1
			return [grid_data[i][0], grid_data[i][1], grid_data[i][2], grid_data[i][3], grid_data[i][4]]
		elif row_sum == -5:
			p2Score += 1
			return [grid_data[i][0], grid_data[i][1], grid_data[i][2], grid_data[i][3], grid_data[i][4]]
		elif col_sum == 5:
			p1Score += 1
			return [grid_data[0][i], grid_data[1][i], grid_data[2][i], grid_data[3][i], grid_data[4][i]]
		elif col_sum == -5:
			p2Score += 1
			return [grid_data[0][i], grid_data[1][i], grid_data[2][i], grid_data[3][i], grid_data[4][i]]

func scoring():
	var five = five_in_a_row()
	if five != null:
		five[0] = 0 # remove those 5 pieces
		five[1] = 0
		five[2] = 0
		five[3] = 0
		five[4] = 0

func win():
	if p1Score == 3:
		pass
		get_tree().paused = true
	elif p2Score == 3:
		pass
		get_tree().paused = true
