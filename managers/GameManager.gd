extends Node
## Global game state. Registered as an autoload (singleton) named "GameManager"
## so any scene can read/update score, coins, lives, etc. and the HUD can listen
## to its signals. Autoloads persist for the whole run of the game.

signal score_changed(value: int)
signal coins_changed(value: int)
signal lives_changed(value: int)
signal time_changed(seconds: float)
signal stars_changed(value: int)
signal combo_changed(value: int)
signal player_died()
signal game_over()
signal level_completed()

const START_LIVES := 3
const COMBO_WINDOW := 2.0  # seconds you have to grab the next coin to keep a combo

var score := 0
var coins := 0
var lives := START_LIVES
var time := 0.0
var stars := 0
var total_stars := 3
var combo := 0

var respawn_point := Vector2.ZERO

var _combo_timer := 0.0
var _timing := false
var _finished := false


func _process(delta: float) -> void:
	if _timing and not _finished:
		time += delta
		time_changed.emit(time)
	if _combo_timer > 0.0:
		_combo_timer -= delta
		if _combo_timer <= 0.0 and combo != 0:
			combo = 0
			combo_changed.emit(combo)


## Called by the level when it loads, to start fresh.
func reset_level(total_star_count: int = 3) -> void:
	score = 0
	coins = 0
	lives = START_LIVES
	time = 0.0
	stars = 0
	combo = 0
	total_stars = total_star_count
	_combo_timer = 0.0
	_timing = true
	_finished = false
	score_changed.emit(score)
	coins_changed.emit(coins)
	lives_changed.emit(lives)
	stars_changed.emit(stars)
	combo_changed.emit(combo)
	time_changed.emit(time)


func add_score(amount: int) -> void:
	score += amount
	score_changed.emit(score)


func add_coin() -> void:
	combo = min(combo + 1, 8)
	_combo_timer = COMBO_WINDOW
	combo_changed.emit(combo)
	coins += 1
	coins_changed.emit(coins)
	add_score(10 * combo)  # combo multiplies the value, rewarding fast collection


func collect_star() -> void:
	stars += 1
	stars_changed.emit(stars)
	add_score(500)


func set_checkpoint(pos: Vector2) -> void:
	respawn_point = pos


## Returns remaining lives after losing one.
func lose_life() -> int:
	lives -= 1
	lives_changed.emit(lives)
	player_died.emit()
	if lives <= 0:
		_timing = false
		SaveManager.record(score, stars)
		game_over.emit()
	return lives


func complete_level() -> void:
	if _finished:
		return
	_finished = true
	_timing = false
	SaveManager.record(score, stars)
	level_completed.emit()
