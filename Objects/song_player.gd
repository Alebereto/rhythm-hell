class_name SongPlayer extends Node

signal song_ended

signal song_played
signal song_paused
signal song_seeked(value: float)


@onready var _audio_player: AudioStreamPlayer = $AudioStreamPlayer


var current_second: float: get = _get_current_second
var current_raw_second: float: get = _get_current_raw_second
var song_length: float

var _playing: bool = false
var _has_song: bool = false

func _get_current_raw_second() -> float: return _audio_player.get_playback_position()
func is_playing() -> bool: return _playing

# variables used to sync time ============
var _song_start_time: float
var _ticks_begin: int
var _time_delay: float



func _physics_process(_delta):
	if _playing: _check_end_song()



func load_song( audio_path: String, song_len=null ) -> void:
	# Load song file to audio stream player
	var audio_stream = AudioStreamOggVorbis.load_from_file( audio_path )
	_audio_player.stream = audio_stream

	# Get song length
	if song_len == null: song_length = _audio_player.stream.get_length()
	else: 				 song_length = song_len

	_has_song = true



## Used to play song from given time
func play() -> void:
	if (not _has_song) or _playing: return

	# get some values for syncing audio time with game time
	_song_start_time = _audio_player.get_playback_position()
	_ticks_begin = Time.get_ticks_usec()
	_time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()

	# If audio stream was paused, resume
	if _audio_player.stream_paused: _audio_player.stream_paused = false
	else: _audio_player.play()	# else play audio stream

	_playing = true
	song_played.emit()

## Used to move playback to given time (also pauses)
func seek(time: float = 0) -> void:
	if not _has_song: return

	_audio_player.play(time)
	_playing = true
	pause()
	song_seeked.emit(time)

## Used to pause song
func pause() -> void:
	if (not _has_song) or (not _playing): return

	_audio_player.stream_paused = true
	song_paused.emit()
	_playing = false



func _get_current_second() -> float:
	if not _has_song: return 0.0
	if not _playing: return _audio_player.get_playback_position()

	var time_played: float = (Time.get_ticks_usec() - _ticks_begin) / Globals.MILISECONDS_IN_SECOND
	return _song_start_time + time_played - _time_delay


func _check_end_song() -> void:
	if current_raw_second >= song_length: _finished_playing()


## Called when song stops playing
func _finished_playing() -> void:
	if not _playing: return
	_playing = false
	song_ended.emit()

