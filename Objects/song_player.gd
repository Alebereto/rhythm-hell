class_name SongPlayer extends Node


@onready var _audio_player = $AudioStreamPlayer

var current_second: float: get = _get_current_second

var _playing: bool = false

var _has_song: bool = false

# variables used to sync time ============
var _song_start_time: float
var _ticks_begin: int
var _time_delay: float


signal song_ended


func load_audio_file(audio_path: String):
	var audio_stream = AudioStreamOggVorbis.load_from_file(audio_path)
	_audio_player.stream = audio_stream

	_has_song = true


## Used to play song from current playback position
func play() -> void:
	if not _has_song: return

	# get some values for syncing audio time with game time
	_song_start_time = _audio_player.get_playback_position()
	_ticks_begin = Time.get_ticks_usec()
	_time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()

	_audio_player.play()
	_playing = true

## Used to move playback to given time (also pauses)
func seek(time: float = 0) -> void:
	if not _has_song: return

	pause()
	_audio_player.seek(time)

## Used to pause song
func pause() -> void:
	if not _has_song: return

	_audio_player.stop()
	_playing = false


func _get_current_second() -> float:
	if not _has_song: return 0.0

	if not _playing: return _audio_player.get_playback_position()

	const MILISECONDS: float = 1000000.0 # a million miliseconds in a second
	var time_played: float = (Time.get_ticks_usec() - _ticks_begin) / MILISECONDS
	var song_time = _song_start_time + time_played - _time_delay
	return song_time


## Called when song stops _playing
func _finished_playing() -> void:
	song_ended.emit()
