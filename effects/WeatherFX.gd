extends CanvasLayer
## Screen-space weather overlay. Listens to WeatherManager and eases between clear
## and stormy: scales the rain, fades a dark overlay, and at full intensity adds
## occasional lightning flashes + a screen shake on the player.

@onready var _rain: CPUParticles2D = $Rain
@onready var _darken: ColorRect = $Darken
@onready var _flash: ColorRect = $Flash

const MAX_RAIN := 130
const MAX_DARK_ALPHA := 0.45

var _intensity: float = 0.0
var _lightning_timer: float = 0.0


func _ready() -> void:
	WeatherManager.weather_changed.connect(_apply)
	_apply(WeatherManager.intensity, true)


func _apply(intensity: float, instant := false) -> void:
	_intensity = intensity
	_rain.emitting = intensity > 0.05
	_rain.amount = maxi(1, int(MAX_RAIN * intensity))
	var target_alpha := MAX_DARK_ALPHA * intensity
	if instant:
		_darken.color.a = target_alpha
	else:
		var tw := create_tween()
		tw.tween_property(_darken, "color:a", target_alpha, 1.0)


func _process(delta: float) -> void:
	if _intensity >= 1.0:
		_lightning_timer -= delta
		if _lightning_timer <= 0.0:
			_lightning_timer = randf_range(2.5, 5.0)
			_strike()


func _strike() -> void:
	_flash.color.a = 0.0
	var tw := create_tween()
	tw.tween_property(_flash, "color:a", 0.65, 0.05)
	tw.tween_property(_flash, "color:a", 0.0, 0.3)
	var player := get_tree().get_first_node_in_group("player")
	if player and player.has_method("add_shake"):
		player.add_shake(4.0, 0.3)
