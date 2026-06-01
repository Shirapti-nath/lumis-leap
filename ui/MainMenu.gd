extends Control
## Title screen. Play starts the level (with a fade), Settings opens the overlay,
## Quit exits (hidden on web). Shows the saved best score/stars.

const SETTINGS_SCENE := "res://ui/Settings.tscn"
const LEVEL := "res://levels/Level_01.tscn"

@onready var _play: Button = $Center/VBox/Play
@onready var _settings: Button = $Center/VBox/Settings
@onready var _quit: Button = $Center/VBox/Quit
@onready var _best: Label = $Center/VBox/Best


func _ready() -> void:
	_play.pressed.connect(func(): SceneManager.change_scene(LEVEL))
	_settings.pressed.connect(_open_settings)
	_quit.pressed.connect(func(): get_tree().quit())
	if OS.has_feature("web"):
		_quit.hide()
	_best.text = "Best  %d      Stars  %d" % [
		int(SaveManager.data.get("best_score", 0)), int(SaveManager.data.get("max_stars", 0))]
	_play.grab_focus()


func _open_settings() -> void:
	var s: Control = load(SETTINGS_SCENE).instantiate()
	add_child(s)
