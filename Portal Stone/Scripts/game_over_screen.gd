extends CanvasLayer

signal restart

func _on_button_pressed():
	restart.emit()
