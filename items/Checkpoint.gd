extends Area2D
## When the player touches it, this becomes the new respawn point and lights up.

var _active := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if _active or not body.is_in_group("player"):
		return
	_active = true
	GameManager.set_checkpoint(global_position)
	modulate = Color(0.6, 1.0, 0.6)  # green tint = "activated"
	var tw := create_tween()
	tw.tween_property($Sprite2D, "scale", Vector2(1.3, 1.3), 0.1)
	tw.tween_property($Sprite2D, "scale", Vector2.ONE, 0.1)
