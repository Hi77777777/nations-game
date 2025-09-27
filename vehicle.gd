extends Sprite2D

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print(event, get_rect(), to_local(event.position))
		if get_rect().has_point(to_local(event.position)):
			print("A click!")
