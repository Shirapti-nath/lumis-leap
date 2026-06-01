extends Area2D
## A hidden collectible star. Spins gently; collected on contact.

var _got := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	var tw := create_tween().set_loops()
	tw.tween_property($Sprite2D, "rotation", TAU, 2.0)


func _on_body_entered(body: Node) -> void:
	if _got or not body.is_in_group("player"):
		return
	_got = true
	GameManager.collect_star()
	AudioManager.play_sfx("powerup")
	FXPool.poof(global_position)
	queue_free()
