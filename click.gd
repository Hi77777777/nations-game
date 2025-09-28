extends Area2D

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and Selections.current_selection_mode == "none":
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			$"../YellowOutline".visible = true
			Selections.current_selection_mode = "to"

func _ready() -> void:
	$"../YellowOutline".visible = false
