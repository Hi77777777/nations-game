extends CharacterBody2D


const SPEED = 1000.0



func _physics_process(delta: float) -> void:




	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("mouseLeft", "mouseRight")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	var upDown := Input.get_axis("mouseUp", "mouseDown")
	if upDown:
		velocity.y = upDown * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)


	move_and_slide()
