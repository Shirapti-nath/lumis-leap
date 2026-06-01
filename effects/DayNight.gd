extends CanvasModulate
## Slowly shifts the world's tint between "day" (bright) and "night" (dim blue)
## over a cycle. CanvasModulate tints everything on the default canvas layer
## (the gameplay world); the HUD/touch UI live on their own layers and stay clear.

@export var cycle_seconds: float = 40.0
@export var day_color: Color = Color(1.0, 1.0, 1.0)
@export var night_color: Color = Color(0.5, 0.55, 0.8)

var _t: float = 0.0


func _process(delta: float) -> void:
	_t += delta
	# 0 = full day, 1 = full night, smoothly oscillating.
	var blend := 0.5 - 0.5 * cos(_t / cycle_seconds * TAU)
	color = day_color.lerp(night_color, blend)
