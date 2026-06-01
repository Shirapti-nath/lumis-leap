extends Node
## Persists best score, best star count, and player settings to user://save.json.
## user:// is a writable, per-user folder Godot manages on every platform (including
## the web export, where it is backed by the browser's IndexedDB).

const PATH := "user://save.json"

signal settings_changed

var data: Dictionary = {
	"best_score": 0,
	"max_stars": 0,
	"settings": {
		"music_volume": 0.8,
		"sfx_volume": 0.9,
		"muted": false,
		"screen_shake": true,
		"touch_force": false,
	},
}


func _ready() -> void:
	load_game()


func load_game() -> void:
	if not FileAccess.file_exists(PATH):
		return
	var f := FileAccess.open(PATH, FileAccess.READ)
	if f == null:
		return
	var text := f.get_as_text()
	f.close()
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	if parsed.has("best_score"):
		data.best_score = int(parsed["best_score"])
	if parsed.has("max_stars"):
		data.max_stars = int(parsed["max_stars"])
	if parsed.has("settings") and typeof(parsed["settings"]) == TYPE_DICTIONARY:
		var s: Dictionary = parsed["settings"]
		for key in data.settings.keys():
			if s.has(key):
				data.settings[key] = s[key]


func save_game() -> void:
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify(data, "\t"))
	f.close()


## Record a finished run; saves only if it beats a previous best.
func record(score: int, stars: int) -> void:
	var changed := false
	if score > int(data.best_score):
		data.best_score = score
		changed = true
	if stars > int(data.max_stars):
		data.max_stars = stars
		changed = true
	if changed:
		save_game()


func get_setting(key: String, default_value: Variant = null) -> Variant:
	return data.settings.get(key, default_value)


func set_setting(key: String, value: Variant) -> void:
	data.settings[key] = value
	save_game()
	settings_changed.emit()
