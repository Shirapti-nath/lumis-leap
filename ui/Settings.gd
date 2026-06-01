extends Control
## Reusable settings overlay. Reads/writes SaveManager; AudioManager and the player
## react automatically (AudioManager listens to settings_changed; add_shake checks the
## shake flag). Emits "closed" and frees itself when Back is pressed.

signal closed

@onready var _music: HSlider = $Center/Panel/VBox/MusicRow/Slider
@onready var _sfx: HSlider = $Center/Panel/VBox/SfxRow/Slider
@onready var _mute: CheckButton = $Center/Panel/VBox/Mute
@onready var _shake: CheckButton = $Center/Panel/VBox/Shake
@onready var _touch: CheckButton = $Center/Panel/VBox/Touch
@onready var _back: Button = $Center/Panel/VBox/Back


func _ready() -> void:
	_music.value = float(SaveManager.get_setting("music_volume", 0.8))
	_sfx.value = float(SaveManager.get_setting("sfx_volume", 0.9))
	_mute.button_pressed = bool(SaveManager.get_setting("muted", false))
	_shake.button_pressed = bool(SaveManager.get_setting("screen_shake", true))
	_touch.button_pressed = bool(SaveManager.get_setting("touch_force", false))

	_music.value_changed.connect(func(v: float): SaveManager.set_setting("music_volume", v))
	_sfx.value_changed.connect(func(v: float): SaveManager.set_setting("sfx_volume", v))
	_mute.toggled.connect(func(on: bool): SaveManager.set_setting("muted", on))
	_shake.toggled.connect(func(on: bool): SaveManager.set_setting("screen_shake", on))
	_touch.toggled.connect(func(on: bool): SaveManager.set_setting("touch_force", on))
	_back.pressed.connect(_on_back)


func _on_back() -> void:
	closed.emit()
	queue_free()
