extends CanvasLayer
## On-screen buttons for phones/tablets. Each TouchScreenButton has an "action"
## that feeds the SAME input actions the keyboard uses, so the player code needs
## no changes. Hidden automatically on devices without a touchscreen (e.g. desktop).


func _ready() -> void:
	# Shown on touch devices, or forced on from Settings (handy for testing on desktop).
	visible = DisplayServer.is_touchscreen_available() or bool(SaveManager.get_setting("touch_force", false))
