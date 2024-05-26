extends Node3D

enum GT {KARATE, BADMIN}

# Game type
@export var game_type: GT = GT.KARATE
# Song name
@export var song_name: String = "test2"
# Song audio file
@export_global_file("*.ogg") var audio_source: String
# Initial BPM of song
@export_range(0,200) var initial_bpm: int = 60
# Location to save song into
@export_dir var songs_dir: String = "res://songs"

@onready var audio_player = $AudioStreamPlayer
@onready var time_line = $TimeLine
@onready var trail = $TimeLine/Trail
@onready var notes_root = $TimeLine/Notes
@onready var time_slider = $Control/TimeSlider

# value of current place in song (seconds)
var track_time: float = 0
var paused: bool = true
# Song length in seconds
var song_length: float = 60

const SAVE_NAME = "save.dat"
const AUDIO_NAME = "song.ogg"

## Gets level information dictionary
func get_level_data() -> Dictionary:
	# Ordered list of notes (by beat)
	var note_list: Array = []
	
	var notes = notes_root.get_children()
	
	for note: Node3D in notes:
		# make map of note info
		var note_info = {
			"b": note.position.z, # note arrival note
			"s": note.position.z -1 # note start note
		}
		# add to list
		note_list.append(note_info)

	# TODO: sort notes by "s" value

	var bpm_events: Array[Dictionary] = []
	
	var save_data = {
		"initial_bpm": initial_bpm,
		"note_list": note_list,
		"bpm_events": bpm_events
	}
	
	return save_data

## Saves song to songs directory
func save_song() -> void:
	
	var save_data = get_level_data()
	var save_data_str = JSON.stringify(save_data)
	
	# make directory for song
	var save_dir = "%s/%s" %[songs_dir, song_name]
	# check if save directory exists
	if not DirAccess.dir_exists_absolute(save_dir):
		DirAccess.make_dir_absolute(save_dir)
	
	# File paths
	var data_path = "%s/%s" %[save_dir, SAVE_NAME]
	var audio_path = "%s/%s" %[save_dir, AUDIO_NAME]
	
	# make data file
	var file = FileAccess.open(data_path, FileAccess.WRITE)
	file.store_string(save_data_str)
	file.close()
	# copy audio file to song directory if not exists
	if not FileAccess.file_exists(audio_source):
		DirAccess.copy_absolute(audio_source, audio_path)

# Called when the node enters the scene tree for the first time.
func _ready():
	# load music file
	audio_player.stream = load(audio_source)
	song_length = audio_player.stream.get_length()
	#if audio_player.stream._get_bpm > 0: initial_bpm = audio_player.stream._get_bpm # maybe change
	
	# set max slider value to music length
	time_slider.max_value = song_length
	var beats = (song_length / 60) * initial_bpm
	trail.scale.z = beats/2
	trail.position.z = beats/2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#track_time = time_slider.value
	#time_line.position.z = -track_time / 60 * initial_bpm
	pass


func _on_save_button_pressed():
	save_song()
