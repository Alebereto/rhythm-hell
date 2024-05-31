class_name Song extends Node

'''
Contains song information
'''

# all song data
var data: Dictionary = {}

# Initial BPM of song (can change with bpmEvents)
var initial_bpm: int: get = _get_initial_bpm
# Ordered array of notes (by starting beat)
var note_list: Array[Dictionary]: get = _get_note_list
# Changes in bpm during song
var bpm_events: Array: get = _get_bpm_events
# Time when first beat comes
var song_offset: float: get = _get_song_offset
# Name of song
var song_name: String: get = _get_song_name
# Song length
var length: float: get = _get_song_length, set = _set_song_length

# Total number of notes in song
var note_count: int: get = _get_note_count

var beat_count: float: get = _get_beat_count


# Getters
func _get_initial_bpm() -> int: return data["initial_bpm"]
func _get_note_list() -> Array: return data["note_list"]
func _get_bpm_events() -> Array: return data["bpm_events"]
func _get_song_offset() -> float: return data["song_offset"]
func _get_song_name() -> String: return data["name"]
func _get_song_length(): return data["length"]

func _get_note_count() -> int: return len(note_list)
func _get_beat_count() -> float: return seconds_to_beats(length)

func _set_song_length(value: float) -> void: data["length"] = value


var audio_path: String = ""


## Constructor
##
func _init(song_path = null):
	
	if song_path != null:
		var data_path = "%s/%s" %[song_path, Globals.SAVE_FILE_NAME]
		audio_path = "%s/%s" %[song_path, Globals.AUDIO_FILE_NAME]

		_get_data_from_file(data_path)
	else:
		data = create_default_data()


## Get data from given save file path
func _get_data_from_file(data_path: String) -> void:
	# get string data from file
	var file = FileAccess.open(data_path, FileAccess.READ)
	var data_str = file.get_as_text()
	file.close()
	# make string data to dictionary
	data = JSON.parse_string(data_str)


func _get_second_in_level(seconds: float) -> float:
	return seconds - song_offset


## Gets second from SongPlayer, reutrns beat in level
func seconds_to_beats(seconds: float) -> float:
	var level_minute = _get_second_in_level(seconds) / 60.0
	var current_bpm = initial_bpm

	if len(bpm_events) == 0: return level_minute * current_bpm

	var prev_event_beat: float = 0
	var beats: float = 0

	for bpm_event in bpm_events:
		var event_beat = bpm_event["s"]
		var event_bpm = bpm_event["bpm"]

		var event_time = (event_beat - prev_event_beat) / current_bpm

		beats += min(event_time, level_minute) * current_bpm

		level_minute -= event_time
		if level_minute <= 0: return beats

		prev_event_beat = event_beat
		current_bpm = event_bpm

	return beats + (level_minute * current_bpm)

## Gets beat in level, returns second in SongPlayer
func beats_to_seconds(beats: float) -> float:
	# TODO: make work with bpm events ======================
	return (beats / initial_bpm) * 60.0



func find_note_idx_after(second: float) -> int:
	var beat = seconds_to_beats(second)
	for i in range(len(note_list)):
		if beat > note_list[i]["s"]: return max(0, i-1)
	return len(note_list)


func create_default_data() -> Dictionary:
	var default_data: Dictionary = {}

	default_data["initial_bpm"] = 100
	default_data["note_list"] = []
	default_data["bpm_events"] = []
	default_data["song_offset"] = 0.0
	default_data["name"] = "My Song"
	default_data["length"] = null
	default_data["items_dict"] = null

	return default_data
