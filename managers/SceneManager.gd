extends Node
## Fade-to-black scene transitions. Owns its own top-most CanvasLayer + ColorRect so
## any scene can request a smooth change without each scene needing transition art.

var _rect: ColorRect
var _busy := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	_rect = ColorRect.new()
	_rect.color = Color(0, 0, 0, 0)
	_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_rect)


func change_scene(path: String) -> void:
	if _busy:
		return
	_busy = true
	await _fade(1.0)
	get_tree().paused = false
	get_tree().change_scene_to_file(path)
	await _fade(0.0)
	_busy = false


func reload() -> void:
	if _busy:
		return
	_busy = true
	await _fade(1.0)
	get_tree().paused = false
	get_tree().reload_current_scene()
	await _fade(0.0)
	_busy = false


func _fade(target_alpha: float) -> void:
	var tw := create_tween()
	tw.tween_property(_rect, "color:a", target_alpha, 0.3)
	await tw.finished
