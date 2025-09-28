extends Area2D

@onready var sprite_texture = load("res://images/red_outline.png")

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and Selections.current_selection_mode == "none":
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			$"../YellowOutline".visible = true
			Selections.current_selection_mode = "to"
			for cell in $"..".get_can_go():
				create_sprite($"../../TileMapLayer".to_global($"../../TileMapLayer".map_to_local(cell)))

func _ready() -> void:
	$"../YellowOutline".visible = false
	create_sprite(Vector2(0, 0))

func create_sprite(position: Vector2) -> void:
	# Create the Sprite2D node
	var sprite = TextureRect.new()
	
	# Set the sprite's texture
	sprite.texture = sprite_texture
	
	# Position the sprite at the mouse click position
	sprite.position = position + Vector2(-95, -82)
	
	sprite.scale = Vector2(1,1)
	
	# Add the sprite to the scene
	$"../..".add_child.call_deferred(sprite)
	
	# Connect input
	sprite.gui_input.connect(func (event):
		if event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			clear_outlines()
			$"../YellowOutline".visible = false
			Selections.current_selection_mode = "none"
			$"..".target_position = $"../../TileMapLayer".local_to_map($"../../TileMapLayer".to_local(position))
	)

func clear_outlines() -> void:
	# Hide yellow outline
	$"../YellowOutline".visible = false
	
	# Remove all TextureRects (red outlines)
	for child in $"../..".get_children():
		if child is TextureRect and child.texture == sprite_texture:
			child.queue_free()
