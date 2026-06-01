extends CanvasLayer
## In-level pause overlay. Toggled with Esc (ui_cancel). Runs with PROCESS_MODE_ALWAYS
## so its buttons and input keep working while the rest of the tree is paused.

const SETTINGS_SCENE := "res://ui/Settings.tscn"
const MAIN_MENU := "res://ui/MainMenu.tscn"

@onready var _root: Control = $Root
@onready var _resume: Button = $Root/Center/Panel/VBox/Resume
@onready var _settings: Button = $Root/Center/Panel/VBox/Settings
@onready var _menu: Button = $Root/Center/Panel/VBox/Menu


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_root.hide()
	_resume.pressed.connect(_resume_game)
	_settings.pressed.connect(_open_settings)
	_menu.pressed.connect(_to_menu)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if _root.visible:
			_resume_game()
		else:
			_pause_game()
		get_viewport().set_input_as_handled()


func _pause_game() -> void:
	_root.show()
	_resume.grab_focus()
	get_tree().paused = true


func _resume_game() -> void:
	_root.hide()
	get_tree().paused = false


func _to_menu() -> void:
	get_tree().paused = false
	SceneManager.change_scene(MAIN_MENU)


func _open_settings() -> void:
	var s: Control = load(SETTINGS_SCENE).instantiate()
	_root.add_child(s)
