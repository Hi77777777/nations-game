extends CharacterBody2D

@onready var tilemap = $"../TileMapLayer"

# State
var tile_position := Vector2.ZERO
var prev_position := Vector2.ZERO
var frame_counter := 0
var frames_per_move := 60  # Change for faster/slower stepping
var units := 9  # Unit count

var target_position = null  # Set to Vector2(x, y) to enable A*
var astar: AStar2D
var map_width := 1
var offset := Vector2.ZERO
var current_path := []

@export var start_cell = Vector2(0, 0)

# Cached walkable cells
var walkable_cells := []
var walkable_set := {} # dictionary keyed by "x:y" for fast lookup

# Neighbours (8 directions)
const NEIGHBOURS := [
	Vector2(0, -1),
	Vector2(0, 1),
	Vector2(-1, 0),
	Vector2(1, 0),
	Vector2(-1, -1),
	Vector2(1, -1),
	Vector2(-1, 1),
	Vector2(1, 1)
]

# -------------------------
# Helpers
# -------------------------
func _cell_key(cell: Vector2) -> String:
	return str(int(cell.x)) + ":" + str(int(cell.y))

func _cell_to_id(cell: Vector2) -> int:
	var shifted = cell - offset
	return int(shifted.y * map_width + shifted.x)

func _id_to_cell(id: int) -> Vector2:
	var sy = floor(id / map_width)
	var sx = id % map_width
	return Vector2(sx, sy) + offset

func is_walkable(cell: Vector2) -> bool:
	return walkable_set.has(_cell_key(cell))

# -------------------------
# Ready
# -------------------------
func _ready() -> void:
	randomize()

	# Gather walkable tiles (IDs 1 and 2)
	var used1 = tilemap.get_used_cells_by_id(1)
	var used2 = tilemap.get_used_cells_by_id(2)

	walkable_cells.clear()
	walkable_set.clear()

	for c in used1:
		var cf = Vector2(c)
		walkable_cells.append(cf)
		walkable_set[_cell_key(cf)] = true

	for c in used2:
		var cf = Vector2(c)
		var k = _cell_key(cf)
		if not walkable_set.has(k):
			walkable_cells.append(cf)
			walkable_set[k] = true

	if walkable_cells.is_empty():
		return

	# Compute bounding box (offset both x and y)
	var min_x = walkable_cells[0].x
	var max_x = walkable_cells[0].x
	var min_y = walkable_cells[0].y
	var max_y = walkable_cells[0].y
	for c in walkable_cells:
		if c.x < min_x: min_x = c.x
		if c.x > max_x: max_x = c.x
		if c.y < min_y: min_y = c.y
		if c.y > max_y: max_y = c.y

	offset = Vector2(min_x, min_y)
	map_width = max(int(max_x - min_x + 1), 1)

	# Start at a random walkable tile
	#var random_cell = walkable_cells.pick_random()
	tile_position = start_cell
	position = tilemap.to_global(tilemap.map_to_local(tile_position))

	# Build the A* graph
	astar = AStar2D.new()
	_build_astar(walkable_cells)

func _build_astar(cells: Array) -> void:
	for cell in cells:
		astar.add_point(_cell_to_id(cell), cell)

	for cell in cells:
		var from_id = _cell_to_id(cell)
		for dir in NEIGHBOURS:
			var n = cell + dir
			if not is_walkable(n):
				continue

			# Prevent corner-cutting
			if dir.x != 0 and dir.y != 0:
				var c1 = cell + Vector2(dir.x, 0)
				var c2 = cell + Vector2(0, dir.y)
				if not (is_walkable(c1) and is_walkable(c2)):
					continue

			var to_id = _cell_to_id(n)
			if not astar.are_points_connected(from_id, to_id):
				astar.connect_points(from_id, to_id)

# -------------------------
# Movement
# -------------------------
func _process(_delta: float) -> void:
	# Collision with other characters
	for child in get_parent().get_children():
		if child is CharacterBody2D and child != self:
			if Vector2i(tile_position) == Vector2i(child.tile_position):
				await get_tree().create_timer(2.0).timeout
				units -= 1
				print(units)
				queue_free()
				return

	# Frame-based stepping
	frame_counter += 1
	if frame_counter >= frames_per_move:
		frame_counter = 0
		if target_position != null:
			_follow_astar()
		else:
			_move_random()

func _move_random() -> void:
	var neighbours := []
	for dir in NEIGHBOURS:
		var neighbour_pos = tile_position + dir
		if is_walkable(neighbour_pos) and neighbour_pos != prev_position:
			neighbours.append(neighbour_pos)

	var next_tile = prev_position
	if neighbours.size() > 0:
		next_tile = neighbours.pick_random()

	prev_position = tile_position
	tile_position = next_tile
	position = tilemap.to_global(tilemap.map_to_local(next_tile))

func _follow_astar() -> void:
	if current_path.is_empty():
		current_path = get_astar_path(tile_position, target_position)
		if current_path.size() > 0 and current_path[0] == tile_position:
			current_path.remove_at(0)

	if current_path.size() > 0:
		var next_tile = current_path.pop_front()
		prev_position = tile_position
		tile_position = next_tile
		position = tilemap.to_global(tilemap.map_to_local(next_tile))

		if Vector2i(tile_position) == Vector2i(target_position):
			target_position = null
			current_path.clear()

func get_astar_path(start: Vector2, goal: Vector2) -> Array:
	if not astar.has_point(_cell_to_id(start)) or not astar.has_point(_cell_to_id(goal)):
		return []
	
	var path = astar.get_point_path(_cell_to_id(start), _cell_to_id(goal))
	return Array(path).map(func(p): return Vector2(round(p.x), round(p.y)))

# -------------------------
# Utility
# -------------------------
func set_target(cell: Vector2) -> void:
	target_position = cell
	current_path.clear()

func get_can_go() -> Array:
	var cells := []
	for id in [1, 2]:
		for c in tilemap.get_used_cells_by_id(id):
			cells.append(Vector2(c))
	return cells
