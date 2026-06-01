extends CPUParticles2D
## A one-shot particle burst that emits once, then deletes itself.
## Spawned by the player, coins, stars, and enemies for "juice".


func _ready() -> void:
	emitting = true
	await get_tree().create_timer(lifetime + 0.2).timeout
	queue_free()
