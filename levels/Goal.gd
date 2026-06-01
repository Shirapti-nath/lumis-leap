extends Area2D
## The finish flag. Touching it completes the level (GameManager shows the banner).

var _done := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if _done or not body.is_in_group("player"):
		return
	_done = true
	GameManager.complete_level()
