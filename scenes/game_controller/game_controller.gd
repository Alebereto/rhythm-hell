class_name GameController extends Node3D

'''
Base for micro-games
'''

signal exit

enum MICRO_GAMES{ KARATE=0 }
const MICRO_GAME_SCENES = [ preload("res://scenes/karate/karate.tscn") ]


# Path to song directory --- temp -----
@export_dir var _song_path: String


@export_group("Game settings")
# seconds timeframe that note needs to be hit
@export_range(0,1) var _hit_timeframe: float = 0.3
@export_range(0,1) var _perfect_timeframe: float = 0.1


# Get Player reference
@onready var _player: Player = $SubViewport/Player
# Get song player
@onready var _song_player: SongPlayer = $SongPlayer


# contains _song information
var _song: Song

# micro game scene reference
var micro_game = null


# index of next note to be played from _song.note_list
var _next_note_idx: int = 0

# stats
var _hit_notes: int = 0
var _perfect_notes: int = 0


# Some values
func _get_paused(): return get_tree().paused
var game_paused: bool: get = _get_paused

func _get_current_beat() -> float: return _song.seconds_to_beats(_song_player.current_second)
var current_beat: float: get = _get_current_beat




# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

# Called every physics frame.
func _physics_process(_delta):
	if not game_paused:
		_check_next_note()




func load_song(song: Song = null) -> void:

	if song == null: song = Song.new(_song_path) # temp testing line

	# Save song info
	_song = song
	_song_player.load_song( _song.audio_path, _song.length )	# load audio to song player

	# Load micro game
	var game_id = MICRO_GAMES.KARATE # TODO: get micro game from song
	await _load_micro_game( game_id )

	await _start_level(0, 15)


func _load_micro_game( game_id: MICRO_GAMES ) -> void:
	# unload micro game if exists
	if micro_game != null: micro_game.queue_free()

	# load micro game
	micro_game = MICRO_GAME_SCENES[ game_id ].instantiate()
	add_child( micro_game )
	if not micro_game.is_node_ready(): await micro_game.ready

	# Connect signals
	micro_game.note_hit.connect( _on_note_hit )
	micro_game.play_sound.connect( _play_sound )

	micro_game.song = _song
	# set player refrence and init some attributes in micro game
	micro_game.set_player(_player)



## If song got to next note, play it and set new next note
func _check_next_note() -> void:
	# if next note is available
	if  not _next_note_idx >= _song.note_count:
		# get next note
		var next_note = _song.note_list[_next_note_idx]
		# if current beat surpasses next note start beat
		if current_beat >= next_note["s"]:
			_play_note(next_note)
			_next_note_idx += 1

## Plays note when arriving
func _play_note( note ) -> void:
	micro_game.play_note(note)

## Gets called when payer hits note
func _on_note_hit(dest_beat: float) -> void:
	var hit_beat: float = current_beat
	var hit_offset = abs(hit_beat - dest_beat)

	if hit_offset <= _hit_timeframe: 	 _hit_notes += 1
	if hit_offset <= _perfect_timeframe: _perfect_notes += 1



## Reset game stats
func _reset_stats() -> void:
	_hit_notes = 0
	_perfect_notes = 0

## Starts level from given time
func _start_level(time: float = 0, delay: float = 1.5) -> void:

	if delay > 0: await get_tree().create_timer(delay, false).timeout

	# set initial stats for level

	_song_player.seek(time)
	# find next note index
	if time == 0: _next_note_idx = 0
	else: 		  _next_note_idx = _song.find_note_idx_after(time)

	# reset stats
	_reset_stats()

	_song_player.play()


func _play_sound( sound ) -> void:
	pass


## Called when game is paused by the user
func _pause() -> void:
	get_tree().paused = true
	_song_player.pause()
	_show_menu()

## Called when game is resumed
func _unpause() -> void:
	get_tree().paused = false
	_song_player.play()
	_close_menu()
	

## Called when _song ends
func _song_end() -> void:
	# TODO: add timer and save some info
	exit.emit()


func _show_menu() -> void:
	pass

func _close_menu() -> void:
	pass



## Called when player pressed menu button
func _on_player_menu_button_pressed():
	if not game_paused: _pause()
	else:				_unpause()
