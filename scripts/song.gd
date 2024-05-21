class_name Song extends Node

'''
Controls song playback and contains song information
'''

const SAVE_NAME = "save.dat"
const AUDIO_NAME = "song.ogg"


# Refrence to music player
var audio_player: AudioStreamPlayer
# all song data
var data: Dictionary

# current bpm
var bpm: int

# getters
func _get_initial_bpm() -> int: return data["initial_bpm"]
func _get_note_list() -> Array: return data["note_list"]
func _get_bpm_events() -> Array: return data["bpm_events"]
func _get_song_offset() -> float: return data["song_offset"]

func _get_current_second() -> float: return audio_player.get_playback_position()
func _get_current_beat() -> float: return seconds_to_beats(current_second)

# Initial BPM of song (can change with bpmEvents)
var initial_bpm: int: get = _get_initial_bpm
# Ordered array of notes (by starting beat)
var note_list: Array[Dictionary]: get = _get_note_list
# Changes in bpm during song
var bpm_events: Array: get = _get_bpm_events
# Time when first beat comes
var song_offset: float: get = _get_song_offset

# Current time in song
var current_second: float: get = _get_current_second
var current_beat: float: get = _get_current_beat


## Emit signal when note plays
signal play_note(note: Dictionary)


## Get data from given save file path
func _get_data(data_path: String) -> void:
	# get string data from file
	var file = FileAccess.open(data_path, FileAccess.READ)
	var data_str = file.get_as_text()
	file.close()
	# make string data to dictionary
	data = JSON.parse_string(data_str)

	# get some starting values
	bpm = initial_bpm

## Constructor
##
## Gets path to song and song player
func _init(song_path: String, audio_stream_player: AudioStreamPlayer):
	
	audio_player = audio_stream_player

	# Get paths for data and audio
	var audio_path = "%s/%s" %[song_path, AUDIO_NAME]
	var data_path = "%s/%s" %[song_path, SAVE_NAME]
	
	# get data from song
	_get_data(data_path)
	# load audio stream
	var audio_stream = AudioStreamOggVorbis.load_from_file(audio_path)
	audio_player.stream = audio_stream


## audio play control
func seek(time: float = 0) -> void:
	audio_player.seek(time)

func pause() -> void:
	audio_player.stop()

func play() -> void:
	audio_player.play()

func beats_to_seconds(beats: float) -> float:
	return (beats / bpm) * 60

## Gets second in song, reutrns beat in song
func seconds_to_beats(seconds: float) -> float:
	return (seconds / 60) * bpm

