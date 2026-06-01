extends Node
## Object pool for one-shot particle bursts ("poofs"). Instead of instancing and
## freeing a Poof every coin/stomp/land (which churns memory and the GC), we keep a
## small set of reusable CPUParticles2D and just restart whichever one is idle.
## Autoloads are children of the root viewport, so these Node2Ds render in world space.

const SPARK := "res://assets/spark.png"
const MAX_NODES := 24

var _pool: Array[CPUParticles2D] = []
var _spark_tex: Texture2D


func _ready() -> void:
	if ResourceLoader.exists(SPARK):
		_spark_tex = load(SPARK)


## Fire a burst at a world position.
func poof(pos: Vector2, color: Color = Color(1, 1, 0.85)) -> void:
	var p := _acquire()
	if p == null:
		return
	p.global_position = pos
	p.modulate = color
	p.restart()


func _acquire() -> CPUParticles2D:
	for p in _pool:
		if is_instance_valid(p) and not p.emitting:
			return p
	if _pool.size() >= MAX_NODES:
		# Reuse the oldest even if still emitting, to keep the pool bounded.
		return _pool[0]
	var fresh := _make()
	_pool.append(fresh)
	add_child(fresh)
	return fresh


func _make() -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.emitting = false
	p.one_shot = true
	p.amount = 14
	p.lifetime = 0.5
	p.explosiveness = 0.9
	p.texture = _spark_tex
	p.direction = Vector2(0, -1)
	p.spread = 180.0
	p.gravity = Vector2(0, 420)
	p.initial_velocity_min = 60.0
	p.initial_velocity_max = 150.0
	p.scale_amount_min = 0.4
	p.scale_amount_max = 0.9
	return p
