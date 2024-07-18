extends Node

enum Turn {PLAYER1, PLAYER2}

@onready var board = load("res://scripts/board.gd")
var turn := Turn.PLAYER2
var piece = preload("res://Scenes/pieces.tscn")
var p1Score := 0
var p2Score := 0

func _process(_delta):
	$UI/p1Score.text = "Player 1 : " + str(p1Score)
	$UI/p2Score.text = "Player 2 : " + str(p2Score)
	board.select_tile()
	if Input.is_action_just_released("click"):
		summon(board)
		turnChange()

func turnChange():
	if turn == Turn.PLAYER1:
		turn = Turn.PLAYER2
	elif turn == Turn.PLAYER2:
		turn = Turn.PLAYER1

func summon(_board_data):
	piece.instantiate()
	piece.position = board.position
	$Pieces.add_child(piece)
