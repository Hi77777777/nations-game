extends CharacterBody2D


var ABABA := Vector2.ZERO


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("nuke"):
		$"..".show()
		$"../../Sprite2D/AnimationPlayer".play("nuke")
