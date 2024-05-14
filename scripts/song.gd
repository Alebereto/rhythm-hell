class_name Song extends Node

const SAVE_NAME = "save.dat"
const TRACK_NAME = "track.ogg"


# Path to music track
var audio_path: String
# Initial BPM of song (can change with bpmEvents)
var initial_bpm: int
# Changes in bpm during song
var bpm_events: Array = []
# Ordered list of notes (by beat)
var beat_list: Array = []

## Get data from given save file path
func _get_data(data_path: String) -> void:
	# get string data from file
	var file = FileAccess.open(data_path, FileAccess.READ)
	var song_data_str = file.get_as_text()
	file.close()
	# make string data to dictionary
	var song_data = JSON.parse_string(song_data_str)
	
	# save dictionary values to class members
	beat_list = song_data["beat_list"]
	initial_bpm = song_data["initial_bpm"]

## Constructor
##
## Gets path to song and loads song
func _init(song_path: String):
	var data_path = "%s/%s" %[song_path, SAVE_NAME]
	_get_data(data_path)
	audio_path = "%s/%s" %[song_path, TRACK_NAME]
