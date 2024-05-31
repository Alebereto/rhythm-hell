class_name GameController extends Node3D

'''
Base class for micro-games
'''

signal note_started(note: Dictionary)

# Path to song directory
@export_dir var song_path: String
# get Player refrence
@export var player: Player

# game settings =============

# seconds that note needs to be hit 
@export_group("Game settings")
@export_range(0,1) var perfect_timeframe: float = 0.1
@export_range(0,1) var hit_timeframe: float = 0.3

# Get song player
@onready var song_player: SongPlayer = $SongPlayer

# contains song information
var song: Song
# OpenXR interface ======================
var interface: XRInterface

# true if game is paused
var game_paused: bool = true
# index of next note to be played from song.note_list
var next_note_idx: int = 0


# stats
var hit_notes: int = 0
var perfect_notes: int = 0
var missed_notes: int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	song = Song.new(song_path)
	song_player.load_audio_file(song.audio_path)
	
	_start_song()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _physics_process(_delta):
	_check_next_note()



func _reset_stats() -> void:
	hit_notes = 0
	perfect_notes = 0
	missed_notes = 0

func _get_current_beat() -> float:
	return song.seconds_to_beats(song_player.current_second)


## If song got to next note, play it and set new next note
func _check_next_note() -> void:
	# if game is not paused and next note is available
	if not game_paused and not (next_note_idx >= song.note_count):
		# get next note
		var next_note = song.note_list[next_note_idx]
		# if current beat surpasses next note start beat
		if _get_current_beat() >= next_note["s"]:
			note_started.emit(next_note)
			next_note_idx += 1

## Starts song from given time
func _start_song(time: float = 0) -> void:

	# set initial stats for song

	song_player.seek(time)
	# find next note index
	if time == 0: next_note_idx = 0
	else: next_note_idx = song.find_note_idx_after(time)

	# reset stats
	_reset_stats()

	_play()

func _pause() -> void:
	game_paused = true

	song_player.pause()
	# pause physics
	# pause menu????

func _play() -> void:
	game_paused = false

	song_player.play()
	# unpause physics

## Called when song ends
func _song_end() -> void:
	pass
