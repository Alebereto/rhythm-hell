class_name Level extends RefCounted

'''
Contains level information
'''

# Level name
var name: String = "My Level"
# Level length in seconds. if set to null, level editor will pick length to be song length
var length = null

# Initial BPM of song (can change with bpmEvents)
var initial_bpm: int = 100
# Changes in bpm during song
var bpm_events: Array = []

# Ordered array of notes (by starting beat)
var note_list: Array[Globals.NoteInfo] = []

# Time in song when first beat comes
var song_offset: float = 0.0

var micro_game_id: Globals.MICRO_GAMES = Globals.MICRO_GAMES.KARATE

var items_dict = null


var beat_count: float:
	get: return seconds_to_beats(length)


# Path to song file
var song_audio_path: String = ""

# Level icon texture
var texture = Globals.GODOT_IMAGE


var hit_notes = 0
var perfect_notes = 0


## Constructor
##
func _init(level_path = null):
	
	if level_path != null:
		
		# Load image texture
		var image_path = level_path + "/" + Globals.LEVEL_IMAGE_NAME
		if FileAccess.file_exists(image_path):
			texture = Globals.load_external_image(image_path)
		# Get song path
		song_audio_path = "%s/%s" %[level_path, Globals.AUDIO_FILE_NAME]
		# Load data
		var data_path = "%s/%s" %[level_path, Globals.SAVE_FILE_NAME]
		_get_data_from_file(data_path)





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



func get_total_notes() -> int:
	var note_count = 0
	for note in note_list:
		var id = note.id
		match micro_game_id:
			Globals.MICRO_GAMES.KARATE:
				match id:
					Globals.PROJECTILES.ROCK: note_count += 1
					Globals.PROJECTILES.BARREL: note_count += 2	# TODO: check contained projectile recursively
			Globals.MICRO_GAMES.MOLE_TURF:
				match id:
					Globals.MOLE_TYPES.NORMAL: note_count += 1
					Globals.MOLE_TYPES.FAST: note_count += 2
					Globals.MOLE_TYPES.SLOW: note_count += 3
			
	return note_count


func get_clear_value():
	const PERFECT_RATIO = 0.3
	var total_notes = get_total_notes()
	if total_notes == 0: return 0
	return (1-PERFECT_RATIO) * (hit_notes / float(total_notes)) + PERFECT_RATIO * (perfect_notes / float(total_notes))


## Functions for loading and saving level =======================================


## Get data from given (legal) save file path
func _get_data_from_file(data_path: String) -> void:
	# get string data from file
	var file = FileAccess.open(data_path, FileAccess.READ)
	var data_str = file.get_as_text()
	file.close()
	# make string data to dictionary
	var data: Dictionary = JSON.parse_string(data_str)

	# load data from dictionary
	_load_from_dictionary(data)


## Save level data into dictionary format
func to_dictionary() -> Dictionary:
	# Convert note list into dictionary list
	var note_dict_list = []
	for note_info: Globals.NoteInfo in note_list:
		note_dict_list.append(note_info.get_info_dict())

	var dict := {
		"name"			= name,
		"micro_game_id"	= micro_game_id,
		"length"		= length,
		"initial_bpm"	= initial_bpm,
		"song_offset"	= song_offset,
		"note_list"		= note_dict_list,
		"items_dict"	= items_dict,
	}

	return dict


func _load_from_dictionary(dict: Dictionary) -> void:
	name 			= dict["name"]
	length 			= dict["length"]
	initial_bpm 	= dict["initial_bpm"]
	song_offset 	= dict["song_offset"]
	items_dict		= dict["items_dict"]
	micro_game_id	= dict["micro_game_id"]

	# get note list
	note_list = []
	for note_dict in dict["note_list"]:
		var note_info: Globals.NoteInfo = Globals.NoteInfo.new(note_dict)
		note_list.append(note_info)


func create_copy() -> Level:
	var copied_level = Level.new()
	copied_level._load_from_dictionary(to_dictionary())
	copied_level.song_audio_path = song_audio_path
	return copied_level
