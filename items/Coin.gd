extends Area2D
## A collectible coin. When the player's body enters this Area2D, we tell the
## GameManager and remove the coin. Uses the Area2D "body_entered" signal.

var _collected := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# Tween-driven motion: opt out of physics interpolation to avoid jitter.
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	# Gentle bobbing so coins feel alive (relative moves up then back down).
	var tw := create_tween().set_loops()
	tw.tween_property(self, "position:y", -4.0, 0.5).as_relative() \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(self, "position:y", 4.0, 0.5).as_relative() \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _on_body_entered(body: Node) -> void:
	if _collected or not body.is_in_group("player"):
		return
	_collected = true
	GameManager.add_coin()
	AudioManager.play_sfx("coin")
	FXPool.poof(global_position)
	queue_free()
