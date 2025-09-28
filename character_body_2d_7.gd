extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("nuke"):
		AnimatedSprite2D.play(default)
