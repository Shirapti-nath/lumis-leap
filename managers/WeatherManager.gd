extends Node
## Maps the player's remaining lives to a weather "intensity" (0 = clear, 1 = storm)
## and broadcasts it. WeatherFX (in the level) listens and renders rain/darkness/
## lightning. Keeping this as an autoload means weather state survives between
## nodes and any system can react to it later (e.g. music).

signal weather_changed(intensity: float)

var intensity: float = 0.0


func _ready() -> void:
	GameManager.lives_changed.connect(_on_lives_changed)


func _on_lives_changed(lives: int) -> void:
	intensity = intensity_for(lives)
	weather_changed.emit(intensity)


func intensity_for(lives: int) -> float:
	if lives >= 3:
		return 0.0   # clear
	elif lives == 2:
		return 0.5   # windy / cloudy
	else:
		return 1.0   # storm (rain + lightning)
