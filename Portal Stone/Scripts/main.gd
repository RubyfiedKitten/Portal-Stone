extends Node2D

var Pieces = load("res://Scenes/pieces.tscn")
const grid_offset = 15
const grid_size := 5
const cell_size : float = 100
var winner = null
var cells = {}
var p1Score = 0
var p2Score = 0
var selected_cell
var turn := 1
var direction : Vector2 
var piece = []
var count = 1
var pushed = null
var mouse_swapped := false
var turn_and_color = {1 : Color("RED"), 2 : Color("GREEN")}
var players_and_turns = {1: 1, 2: 0}

func _ready(): # Generates the grids
	$GameOverScreen.hide()
	get_tree().paused = false
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
	$ui/feedback.text = "It is player " + str(turn) + "'s turn."
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
	$ui/feedback4.text = "Turns: " + str(players_and_turns[turn])

	if Input.is_action_just_released("click"):
		selected_cell = get_cell()
		the_click_function()

	if p1Score == 3:
		winner = 1
		win()
	elif p2Score == 3:
		winner = 2
		win()

func check_next(cell): # check for gap
	cell = cell + direction * count
	if not (cell.x < 0 or cell.x > 4 or cell.y < 0 or cell.y > 4): # Checks if the piece is still on the board.
		var result = piece[cell.x][cell.y]
		if result != null: 	# there's a piece, move along
			count += 1
			return false
		else: 				# GAP
			return true
	else: 					# else it's a pushed piece
		count -= 1
		cell = cell - direction
		if players_and_turns[turn] == 1:
			pushed = piece[cell.x][cell.y].modulate
			if pushed == turn_and_color[turn]: #If you push off your own piece:
				pushed = null						#delete it
				
			else:
				pushed = null
				players_and_turns[3 - turn] += 1
			piece[cell.x][cell.y].queue_free()
			piece[cell.x][cell.y] = null
			return true
		else:
			$ui/feedback.text = "Can't push with a pushed piece!"

func find_gap(cell):
	if piece[cell.x][cell.y] == null:
		summon_piece(cell)
	else:
		while check_next(cell) == false:
			pass
		for n in count:
			move_piece(cell + (direction *(count - 1)))
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
	piece[x][y] = Pieces.instantiate()
	piece[x][y].modulate = turn_and_color[turn]
	$"pieces storage".add_child(piece[x][y])
	piece[x][y].new_position = piece_location
	piece[x][y].global_position = cells[piece_location]
	check_rows_and_cols()
	turn_change()
	$ui/feedback.text = "It is player " + str(turn) + "'s turn."

func turn_change():
	if players_and_turns[turn] > 1:
		players_and_turns[turn] -= 1
	else:
		players_and_turns[turn] -= 1
		players_and_turns[3 - turn] += 1
		turn = 3 - turn

func check_edge(cell): # will return true or false
	if (cell.x == 0 or cell.x == 4) or (cell.y == 0 or cell.y == 4):
		return true
	else:
		return false

func move_piece(cell):
	var next_cell = cell + direction
	piece[next_cell.x][next_cell.y] = piece[cell.x][cell.y]
	var tween = get_tree().create_tween()
	tween.tween_property(piece[next_cell.x][next_cell.y],"global_position",cells[next_cell],0.1).set_trans(Tween.TRANS_SINE)
	piece[cell.x][cell.y] = null

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
		mouse_swapped = !mouse_swapped

	if event is InputEventMouseMotion:
		var cell_cords = get_cell()
		if cell_cords != null:
			if cell_cords.x == 0:
				set_mouse("left")
			elif cell_cords.x == 4:
				set_mouse("right")
			elif cell_cords.y == 0:
				set_mouse("top")
			elif cell_cords.y == 4:
				set_mouse("bottom")
			
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

func five_in_a_row(y):
	var matching = true
	for x in grid_size - 1:
		if piece[0][y] != null and piece[x+1][y] != null:
			if piece[0][y].modulate != piece[x+1][y].modulate: 
				matching = false
				break 
		else:
			matching = false
	return matching

func five_in_a_col(x):
	var matching = true
	for y in grid_size - 1:
		if piece[x][0] != null and piece[x][y+1] != null:
			if piece[x][0].modulate != piece[x][y+1].modulate: 
				matching = false
				break 
		else:
			matching = false
	return matching

func check_rows_and_cols():
	var color
	for row in 5:
		if five_in_a_row(row):
			color = piece[0][row].modulate
			for i in 5:
				piece[i][row].queue_free()
				piece[i][row] = null
			if Color("RED") == color:
				p1Score += 1
			else:
				p2Score += 1
	 
	for col in 5:
		if five_in_a_col(col):
			color = piece[col][0].modulate
			for i in 5:
				piece[col][i].queue_free()
				piece[col][i] = null
			if Color("RED") == color:
				p1Score += 1
			else:
				p2Score += 1

func win():
	$GameOverScreen.show()
	$GameOverScreen/ColorRect/Label.text = "Player " + str(winner) + " wins!"
	if winner != null:
		get_tree().paused = true

func is_board_full(): # checks if board is filled
	for x in grid_size:
		for y in grid_size:
			if piece[x][y] == null:
				return false
	return true

func _on_game_over_screen_restart():
	get_tree().reload_current_scene()
