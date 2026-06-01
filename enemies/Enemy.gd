extends Area2D
## Shared enemy/hazard behaviour, configured per-scene via exported values:
##  - Bird:   bob_amp > 0 (sine-wave flight)
##  - Walker: bob_amp = 0 (flat ground patrol)
##  - Spike:  speed = 0, stompable = false (static hazard)
## Stomp (player falling onto its head) defeats stompable enemies; any other
## contact damages the player.

@export var speed: float = 70.0
@export var range_x: float = 160.0       # patrol distance left/right of its start
@export var bob_amp: float = 0.0         # vertical sine amplitude (flying enemies)
@export var bob_speed: float = 3.0
@export var start_dir: float = -1.0
@export var score_value: int = 150
@export var stompable: bool = true

var _origin: Vector2
var _dir: float = -1.0
var _t: float = 0.0
var _dead: bool = false

@onready var _sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	_origin = position
	_dir = start_dir
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	if _dead:
		return
	_t += delta
	if speed != 0.0:
		position.x += _dir * speed * delta
		if position.x > _origin.x + range_x:
			position.x = _origin.x + range_x
			_dir = -1.0
		elif position.x < _origin.x - range_x:
			position.x = _origin.x - range_x
			_dir = 1.0
		_sprite.flip_h = _dir > 0.0
	if bob_amp > 0.0:
		position.y = _origin.y + sin(_t * bob_speed) * bob_amp


func _on_body_entered(body: Node) -> void:
	if _dead or not body.is_in_group("player"):
		return
	var stomped: bool = stompable and body.velocity.y > 0.0 \
		and body.global_position.y < global_position.y - 6.0
	if stomped:
		_defeat(body)
	elif body.has_method("take_damage"):
		body.take_damage()


func _defeat(body: Node) -> void:
	_dead = true
	GameManager.add_score(score_value)
	if body.has_method("bounce"):
		body.bounce()
	AudioManager.play_sfx("stomp")
	FXPool.poof(global_position)
	queue_free()
