extends CharacterBody2D


var ABABA := Vector2.ZERO


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("nuke"):
		$"..".show()
		$"../../AudioStreamPlayer".stop()
		$"../../Sprite2D/AnimationPlayer".play("nuke")
		await get_tree().create_timer(1.55).timeout
		$"../../AudioStreamPlayer2".play()
		await get_tree().create_timer(0.25).timeout
		$"../../AudioStreamPlayer2".play()
		
		await get_tree().create_timer(1).timeout
		
		$"../../CanvasLayer".show()
