extends CharacterBody2D
## Lumi, the player. Handles running, jumping (single/double/variable/coyote/buffer),
## air-dash, wall-slide + wall-jump, taking damage, growing, and "juice" (squash &
## stretch, screen shake, hit-stop). Optional effects load safely at runtime, so the
## script still works even before those scenes exist.

# --- Run / jump tuning (editable in the Inspector) ---
@export var speed: float = 220.0
@export var acceleration: float = 1800.0
@export var friction: float = 2000.0
@export var jump_velocity: float = -430.0
@export var max_fall_speed: float = 700.0
@export var max_jumps: int = 2

@export var coyote_time: float = 0.10
@export var jump_buffer_time: float = 0.10

# --- Dash ---
@export var dash_speed: float = 520.0
@export var dash_time: float = 0.16
@export var dash_cooldown: float = 0.40

# --- Wall movement ---
@export var wall_slide_speed: float = 120.0
@export var wall_jump_push: float = 320.0

# --- Combat / misc ---
@export var kill_y: float = 1200.0       # falling past this = death
@export var stomp_bounce: float = -320.0 # upward velocity after bouncing on an enemy
@export var big_scale: float = 1.4

const POOF_PATH := "res://effects/Poof.tscn"

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var jumps_left: int = 0
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0

var _dash_timer: float = 0.0
var _dash_cd: float = 0.0
var _can_dash: bool = true
var _dash_dir: float = 1.0

var is_big: bool = false
var is_invincible: bool = false
var _dead: bool = false
var _facing: float = 1.0

var _shake_time: float = 0.0
var _shake_strength: float = 0.0
var _was_on_floor: bool = false

@onready var _sprite: AnimatedSprite2D = $Sprite2D
@onready var _camera: Camera2D = $Camera2D
@onready var _shape: CollisionShape2D = $CollisionShape2D

var _base_scale: Vector2 = Vector2.ONE
var _target_scale: Vector2 = Vector2.ONE


func _ready() -> void:
	add_to_group("player")
	_base_scale = _sprite.scale
	_target_scale = _base_scale


func _physics_process(delta: float) -> void:
	if _dead:
		_process_shake(delta)
		return

	_update_timers(delta)

	if _dash_timer > 0.0:
		_process_dash(delta)
	else:
		_apply_gravity(delta)
		_handle_wall_slide()
		_handle_jump()
		_handle_dash()
		_handle_run(delta)

	move_and_slide()
	_post_move(delta)

	if global_position.y > kill_y:
		die()


func _update_timers(delta: float) -> void:
	jump_buffer_timer -= delta
	_dash_cd -= delta
	if is_on_floor():
		jumps_left = max_jumps
		coyote_timer = coyote_time
		_can_dash = true
	else:
		coyote_timer -= delta


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
		velocity.y = min(velocity.y, max_fall_speed)


func _handle_wall_slide() -> void:
	if not is_on_floor() and is_on_wall_only() and velocity.y > 0.0:
		velocity.y = min(velocity.y, wall_slide_speed)


func _handle_jump() -> void:
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time

	var grounded := is_on_floor() or coyote_timer > 0.0

	if jump_buffer_timer > 0.0:
		if grounded or jumps_left > 0:
			velocity.y = jump_velocity
			jumps_left -= 1
			jump_buffer_timer = 0.0
			coyote_timer = 0.0
			_stretch()
			AudioManager.play_sfx("jump")
		elif is_on_wall_only():
			var n := get_wall_normal()
			velocity.y = jump_velocity
			velocity.x = n.x * wall_jump_push
			_facing = signf(n.x)
			jump_buffer_timer = 0.0
			_stretch()
			AudioManager.play_sfx("jump")

	# Variable jump height: release early for a shorter hop.
	if Input.is_action_just_released("jump") and velocity.y < jump_velocity * 0.5:
		velocity.y = jump_velocity * 0.5


func _handle_dash() -> void:
	if Input.is_action_just_pressed("dash") and _can_dash and _dash_cd <= 0.0:
		_dash_dir = _facing
		_dash_timer = dash_time
		_dash_cd = dash_cooldown
		_can_dash = false
		_stretch()
		AudioManager.play_sfx("dash")


func _process_dash(delta: float) -> void:
	_dash_timer -= delta
	velocity.x = _dash_dir * dash_speed
	velocity.y = 0.0


func _handle_run(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0.0:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
		_facing = signf(direction)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)


func _post_move(delta: float) -> void:
	if absf(velocity.x) > 1.0:
		_sprite.flip_h = _facing < 0.0

	# Landing this frame -> squash + dust + tiny shake.
	if is_on_floor() and not _was_on_floor and velocity.y >= 0.0:
		_squash()
		_spawn_poof(global_position + Vector2(0, 20))
		add_shake(2.0, 0.12)
	_was_on_floor = is_on_floor()

	_update_animation()
	_process_shake(delta)


func _update_animation() -> void:
	var anim := "idle"
	if _dash_timer > 0.0:
		anim = "dash"
	elif not is_on_floor():
		anim = "jump" if velocity.y < 0.0 else "fall"
	elif absf(velocity.x) > 12.0:
		anim = "run"
	if _sprite.animation != anim:
		_sprite.play(anim)


# ---------------------------------------------------------------------------
# Combat (called by enemies)
# ---------------------------------------------------------------------------

func bounce(strength: float = NAN) -> void:
	if is_nan(strength):
		strength = stomp_bounce
	velocity.y = strength
	jumps_left = max_jumps  # refresh air options after a stomp
	_squash()
	add_shake(3.0, 0.1)
	hit_stop(0.05)


func take_damage() -> void:
	if is_invincible or _dead:
		return
	if is_big:
		set_big(false)
		add_shake(5.0, 0.2)
		hit_stop(0.07)
		_start_iframes(1.0)
		AudioManager.play_sfx("hurt")
	else:
		die()


func die() -> void:
	if _dead:
		return
	_dead = true
	velocity = Vector2.ZERO
	add_shake(6.0, 0.3)
	_spawn_poof(global_position)
	AudioManager.play_sfx("hurt")
	GameManager.lose_life()
	await get_tree().create_timer(0.6).timeout
	if GameManager.lives > 0:
		_respawn()


func _respawn() -> void:
	_dead = false
	is_invincible = false
	velocity = Vector2.ZERO
	set_big(false)
	global_position = GameManager.respawn_point
	# Teleport: don't let physics interpolation streak the player across the screen.
	reset_physics_interpolation()
	_sprite.modulate = Color.WHITE


# ---------------------------------------------------------------------------
# Power-up / grow
# ---------------------------------------------------------------------------

func set_big(value: bool) -> void:
	is_big = value
	_target_scale = _base_scale * (big_scale if value else 1.0)
	var tw := create_tween()
	tw.tween_property(_sprite, "scale", _target_scale, 0.15)


func _start_iframes(duration: float) -> void:
	is_invincible = true
	var blink := create_tween()
	blink.set_loops(maxi(1, int(duration / 0.2)))
	blink.tween_property(_sprite, "modulate:a", 0.3, 0.1)
	blink.tween_property(_sprite, "modulate:a", 1.0, 0.1)
	await get_tree().create_timer(duration).timeout
	is_invincible = false
	_sprite.modulate.a = 1.0


# ---------------------------------------------------------------------------
# Juice helpers
# ---------------------------------------------------------------------------

func _stretch() -> void:
	_sprite.scale = Vector2(_target_scale.x * 0.8, _target_scale.y * 1.2)
	var tw := create_tween()
	tw.tween_property(_sprite, "scale", _target_scale, 0.12)


func _squash() -> void:
	_sprite.scale = Vector2(_target_scale.x * 1.25, _target_scale.y * 0.75)
	var tw := create_tween()
	tw.tween_property(_sprite, "scale", _target_scale, 0.12)


func add_shake(strength: float, duration: float) -> void:
	# Accessibility: players who dislike camera shake can switch it off in Settings.
	if not SaveManager.get_setting("screen_shake", true):
		return
	_shake_strength = maxf(_shake_strength, strength)
	_shake_time = maxf(_shake_time, duration)


func _process_shake(delta: float) -> void:
	if _shake_time > 0.0:
		_shake_time -= delta
		_camera.offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * _shake_strength
	else:
		_camera.offset = _camera.offset.lerp(Vector2.ZERO, 0.3)


func hit_stop(duration: float = 0.06) -> void:
	Engine.time_scale = 0.05
	# ignore_time_scale = true so the timer still fires while the game is slowed.
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0


func _spawn_poof(at: Vector2) -> void:
	FXPool.poof(at)
