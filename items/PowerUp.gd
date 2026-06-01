extends Area2D
## A "grow" power-up. Makes the player big; a big player survives one hit
## (shrinking instead of dying), Mario-mushroom style.

var _used := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	var tw := create_tween().set_loops()
	tw.tween_property(self, "position:y", -5.0, 0.6).as_relative() \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(self, "position:y", 5.0, 0.6).as_relative() \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _on_body_entered(body: Node) -> void:
	if _used or not body.is_in_group("player"):
		return
	_used = true
	if body.has_method("set_big"):
		body.set_big(true)
	GameManager.add_score(300)
	AudioManager.play_sfx("powerup")
	FXPool.poof(global_position)
	queue_free()
