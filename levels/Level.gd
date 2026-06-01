extends Node2D
## Attached to a level root. Resets game state on load, records the player's start
## as the first respawn point, and clamps the player's camera to the level bounds
## so the view never scrolls past the edges (that bounded feel classic platformers have).

@export var level_bounds: Rect2 = Rect2(0, -400, 6200, 1200)
@export var total_stars: int = 3


func _ready() -> void:
	GameManager.reset_level(total_stars)
	var player := get_node_or_null("Player")
	if player == null:
		return
	GameManager.set_checkpoint(player.global_position)
	var cam := player.get_node_or_null("Camera2D") as Camera2D
	if cam:
		cam.limit_left = int(level_bounds.position.x)
		cam.limit_top = int(level_bounds.position.y)
		cam.limit_right = int(level_bounds.position.x + level_bounds.size.x)
		cam.limit_bottom = int(level_bounds.position.y + level_bounds.size.y)
