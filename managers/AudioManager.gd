extends Node
## Central audio. Creates SFX buses at runtime and synthesises short sound effects
## procedurally (no third-party/copyrighted audio). Background music is intentionally
## off — only gameplay SFX play. Volumes/mute come from SaveManager.

const SFX_VOICES := 6
const MIX_RATE := 22050

var _sfx_players: Array[AudioStreamPlayer] = []
var _sfx: Dictionary = {}


func _ready() -> void:
	_ensure_buses()
	for i in SFX_VOICES:
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_sfx_players.append(p)

	_build_sfx()
	_apply_settings()
	SaveManager.settings_changed.connect(_apply_settings)


func play_sfx(sound_name: String) -> void:
	if not _sfx.has(sound_name):
		return
	var voice := _free_voice()
	voice.stream = _sfx[sound_name]
	voice.play()


# ---------------------------------------------------------------------------
# Buses + settings
# ---------------------------------------------------------------------------

func _ensure_buses() -> void:
	if AudioServer.get_bus_index("Music") == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "Music")
	if AudioServer.get_bus_index("SFX") == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "SFX")


func _apply_settings() -> void:
	var muted: bool = bool(SaveManager.get_setting("muted", false))
	var music_v := float(SaveManager.get_setting("music_volume", 0.8))
	var sfx_v := float(SaveManager.get_setting("sfx_volume", 0.9))
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), muted)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(maxf(music_v, 0.0001)))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(maxf(sfx_v, 0.0001)))


func _free_voice() -> AudioStreamPlayer:
	for p in _sfx_players:
		if not p.playing:
			return p
	return _sfx_players[0]


# ---------------------------------------------------------------------------
# Procedural sound synthesis
# ---------------------------------------------------------------------------

func _build_sfx() -> void:
	_sfx = {
		"jump": _tone(420.0, 0.18, 0.5, "square", 380.0),
		"coin": _tone(950.0, 0.12, 0.4, "sine", 600.0),
		"stomp": _tone(190.0, 0.18, 0.6, "square", -90.0),
		"hurt": _tone(320.0, 0.35, 0.5, "saw", -260.0),
		"powerup": _tone(500.0, 0.30, 0.45, "square", 700.0),
		"dash": _tone(600.0, 0.12, 0.4, "square", 480.0),
	}


func _tone(freq: float, dur: float, vol: float, wave: String, sweep: float) -> AudioStreamWAV:
	var n := int(MIX_RATE * dur)
	var bytes := PackedByteArray()
	bytes.resize(n * 2)
	for i in n:
		var t := float(i) / MIX_RATE
		var f := freq + sweep * t
		var phase := TAU * f * t
		var s := 0.0
		match wave:
			"square":
				s = signf(sin(phase))
			"saw":
				s = fmod(f * t, 1.0) * 2.0 - 1.0
			_:
				s = sin(phase)
		var env := exp(-3.0 * t / dur) * minf(1.0, t / 0.005)
		var val := int(clampf(s * env * vol, -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 2, val)
	return _wav(bytes, false, 0)


func _wav(bytes: PackedByteArray, looping: bool, loop_end: int) -> AudioStreamWAV:
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = MIX_RATE
	w.stereo = false
	w.data = bytes
	if looping:
		w.loop_mode = AudioStreamWAV.LOOP_FORWARD
		w.loop_begin = 0
		w.loop_end = loop_end
	return w
