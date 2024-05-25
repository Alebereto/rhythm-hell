class_name Song extends Node

'''
Controls song playback and contains song information
'''

# all song data
var data: Dictionary = {}

# current bpm
var bpm: int

var playing: bool = false

# getters
func _get_initial_bpm() -> int: return data["initial_bpm"]
func _get_note_list() -> Array: return data["note_list"]
func _get_bpm_events() -> Array: return data["bpm_events"]
func _get_song_offset() -> float: return data["song_offset"]

func _get_current_beat() -> float: return seconds_to_beats(current_second)


func _get_note_count() -> int: return len(note_list)

# Initial BPM of song (can change with bpmEvents)
var initial_bpm: int: get = _get_initial_bpm
# Ordered array of notes (by starting beat)
var note_list: Array[Dictionary]: get = _get_note_list
# Changes in bpm during song
var bpm_events: Array: get = _get_bpm_events
# Time when first beat comes
var song_offset: float: get = _get_song_offset


var note_count: int: get = _get_note_count


## Constructor
##
## Gets path to song and song player
func _init(song_path = null):
	
	if song_path != null:
		var data_path = "%s/%s" %[song_path, Globals.SAVE_FILE_NAME]
		_get_data(data_path)


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


func _get_second_in_level(seconds: float) -> float:
	return seconds - song_offset

## Gets second since first beat, reutrns beat in given seconds
func seconds_to_beats(seconds: float) -> float:
	var minutes = seconds / 60
	var current_bpm = initial_bpm

	if len(bpm_events) == 0: return minutes * current_bpm

	var prev_beat: float = 0

	var beats: float = 0

	for bpm_event in bpm_events:
		var event_beat = bpm_event["s"]
		var event_bpm = bpm_event["bpm"]

		var event_time = (event_beat - prev_beat) / current_bpm

		beats += min(event_time, minutes) * current_bpm

		minutes -= event_time
		if minutes <= 0: return beats

		prev_beat = event_beat
		current_bpm = event_bpm

	return beats

