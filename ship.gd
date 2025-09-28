extends CharacterBody2D

var tile_position := Vector2i(0, 0)
var time_passed := 0
var prev_position = null

func move_to_random_neighbour():
	var neighbours := []
	var tilemap = $"../TileMapLayer"
	# Directions to check: up, down, left, right + some extended neighbours
	var directions = [
		Vector2i(0, -1),
		Vector2i(0, 1),
		Vector2i(-1, 0),
		Vector2i(1, 0),
		Vector2i(1, 1),
		Vector2i(-1, 1)
	]

	for dir in directions:
		var neighbour_pos = tile_position + dir
		if tilemap.get_used_cells_by_id(1).has(neighbour_pos) and neighbour_pos != prev_position:
			var neighbour_id = tilemap.get_cell_source_id(neighbour_pos)
			neighbours.append({
				"position": neighbour_pos,
				"id": neighbour_id
			})
	
	prev_position = tile_position
	
	var random_neighbour = neighbours.pick_random()
	
	if typeof(random_neighbour) == TYPE_NIL:
		random_neighbour = {"position":prev_position}
	
	tile_position = random_neighbour["position"]
	self.position = tilemap.to_global(tilemap.map_to_local(random_neighbour["position"])) 

func _process(delta: float) -> void:
	var tank = $"../CharacterBody2D2"
	var plane = $"../CharacterBody2D"
	if tank and self.tile_position == tank.tile_position:
		await get_tree().create_timer(2.0).timeout
		self.queue_free()

	else:
		if plane and self.tile_position == plane.tile_position:
			await get_tree().create_timer(2.0).timeout
			self.queue_free()
	time_passed += 1
	if time_passed % 60 == 0:
		move_to_random_neighbour()

func _ready() -> void:
	randomize()

	var tilemap = $"../TileMapLayer"
	var used_cells = tilemap.get_used_cells_by_id(1)
	
	if used_cells.is_empty():
		return

	var random_cell = used_cells.pick_random()
	tile_position = random_cell

	# Move the character to that tile's world position
	self.position = tilemap.to_global(tilemap.map_to_local(random_cell))
