extends CanvasLayer
## On-screen heads-up display. It does NOT own any game data; it just listens to
## GameManager signals and updates labels with a bit of animation polish
## (count-up score, pulsing combo/coins, a sliding banner, floating +N popups).

@onready var _score: Label = $Root/Margin/Top/Score
@onready var _coins: Label = $Root/Margin/Top/Coins
@onready var _stars: Label = $Root/Margin/Top/Stars
@onready var _time: Label = $Root/Margin/Top/Time
@onready var _lives: Label = $Root/Margin/Top/Lives
@onready var _combo: Label = $Root/Combo
@onready var _banner: Control = $Root/BannerRoot
@onready var _banner_label: Label = $Root/BannerRoot/Label
@onready var _buttons: Control = $Root/BannerRoot/Buttons
@onready var _retry: Button = $Root/BannerRoot/Buttons/Retry
@onready var _next: Button = $Root/BannerRoot/Buttons/Next

var _shown_score: float = 0.0


func _ready() -> void:
	GameManager.score_changed.connect(_on_score)
	GameManager.coins_changed.connect(_on_coins)
	GameManager.stars_changed.connect(_on_stars)
	GameManager.time_changed.connect(_on_time)
	GameManager.lives_changed.connect(_on_lives)
	GameManager.combo_changed.connect(_on_combo)
	GameManager.level_completed.connect(_on_level_completed)
	GameManager.game_over.connect(_on_game_over)

	_retry.pressed.connect(_restart)
	_next.pressed.connect(_restart)  # level select arrives in a later milestone

	# Initial values set directly (no pulse/popup on first paint).
	_shown_score = GameManager.score
	_set_score_display(GameManager.score)
	_coins.text = "COINS %d" % GameManager.coins
	_stars.text = "STAR %d/%d" % [GameManager.stars, GameManager.total_stars]
	_time.text = "TIME %.1f" % GameManager.time
	_lives.text = "LIVES %d" % maxi(GameManager.lives, 0)
	_on_combo(GameManager.combo)
	_banner.hide()


func _on_score(v: int) -> void:
	# Animate the number rolling up to its new value.
	var tw := create_tween()
	tw.tween_method(_set_score_display, _shown_score, float(v), 0.3) \
		.set_trans(Tween.TRANS_QUAD)
	_shown_score = v


func _set_score_display(value: float) -> void:
	_score.text = "SCORE %06d" % int(round(value))


func _on_coins(v: int) -> void:
	_coins.text = "COINS %d" % v
	_pulse(_coins)
	_popup(_coins, "+1")


func _on_stars(v: int) -> void:
	_stars.text = "STAR %d/%d" % [v, GameManager.total_stars]
	_pulse(_stars)


func _on_time(seconds: float) -> void:
	_time.text = "TIME %.1f" % seconds


func _on_lives(v: int) -> void:
	_lives.text = "LIVES %d" % maxi(v, 0)
	_pulse(_lives)


func _on_combo(v: int) -> void:
	if v >= 2:
		_combo.text = "COMBO x%d" % v
		_combo.show()
		_pulse(_combo)
	else:
		_combo.hide()


func _on_level_completed() -> void:
	_next.show()
	_next.text = "Play Again"
	_show_banner("LEVEL COMPLETE!\nScore %d   Time %.1fs   Stars %d/%d" % [
		GameManager.score, GameManager.time, GameManager.stars, GameManager.total_stars])


func _on_game_over() -> void:
	_next.hide()
	_show_banner("GAME OVER")


# ---------------------------------------------------------------------------
# Animation helpers
# ---------------------------------------------------------------------------

func _pulse(node: Control) -> void:
	node.pivot_offset = node.size * 0.5
	node.scale = Vector2(1.35, 1.35)
	var tw := create_tween()
	tw.tween_property(node, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK)


func _popup(anchor: Control, text: String) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_color_override("font_color", Color(1, 0.9, 0.3))
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	label.add_theme_constant_override("outline_size", 4)
	label.position = anchor.global_position + Vector2(0, 16)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Root.add_child(label)
	var tw := create_tween().set_parallel(true)
	tw.tween_property(label, "position:y", label.position.y - 24.0, 0.6)
	tw.tween_property(label, "modulate:a", 0.0, 0.6)
	tw.chain().tween_callback(label.queue_free)


func _show_banner(text: String) -> void:
	_banner_label.text = text
	_banner.show()
	_banner.modulate.a = 0.0
	_banner_label.pivot_offset = _banner_label.size * 0.5
	_banner_label.scale = Vector2(0.6, 0.6)
	var tw := create_tween().set_parallel(true)
	tw.tween_property(_banner, "modulate:a", 1.0, 0.25)
	tw.tween_property(_banner_label, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _restart() -> void:
	SceneManager.reload()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		_restart()
