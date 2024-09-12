class_name GameController extends Node3D

'''
Base for micro-games
'''

# Called when exiting micro game
signal exit

enum MICRO_GAMES{ KARATE=0 }
const MICRO_GAME_SCENES = [ preload("res://scenes/karate/karate.tscn") ]


# Get Player reference
@onready var _player: Player = $Player
# Get song player
@onready var _song_player: SongPlayer = $SongPlayer

@onready var _menu_panel: VRUI = $MenuPanel


# contains _song information
var _song: Song

# micro game scene reference
var micro_game: MicroGame = null


# index of next note to be played from _song.note_list
var _next_note_idx: int = 0

# stats
var _hit_notes: int = 0
var _perfect_notes: int = 0


# Some values
func _get_paused(): return get_tree().paused
var game_paused: bool: get = _get_paused

func _get_current_second() -> float: return _song_player.current_second
var current_second: float: get = _get_current_second

func _get_current_beat() -> float: return _song.seconds_to_beats(current_second)
var current_beat: float: get = _get_current_beat




# Called when the node enters the scene tree for the first time.
func _ready():
	_player.paused.connect(_on_player_paused)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

# Called every physics frame.
func _physics_process(_delta):
	if not game_paused:
		_check_next_note()
		_check_song_end()


## Loads level
func load_song(song: Song) -> void:

	# Load song info
	_song = song
	_song_player.load_song( _song.audio_path, _song.length )	# load audio to song player

	# Load micro game
	var game_id = MICRO_GAMES.KARATE # TODO: get micro game from song
	await _load_micro_game( game_id )

	await _start_level(0, 2)


## Loads micro game
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




## If song got to next note, play it and set new next note
func _check_next_note() -> void:
	# if next note is available
	if  not _next_note_idx >= _song.note_list.size():
		
		var next_note = _song.note_list[_next_note_idx] # get next note
		var start_note_time: float = _song.beats_to_seconds(next_note["s"]) - micro_game.max_note_delay
		# if current beat surpasses next note start beat
		if current_second >= start_note_time:
			_queue_note(next_note)
			_next_note_idx += 1

func _check_song_end() -> void:
	if _song_player.current_second >= _song.length: _song_end()


## Adds next note to queue
func _queue_note( note ) -> void:
	micro_game.add_note_to_queue(note)

## Gets called when payer hits note
func _on_note_hit(dest_beat: float) -> void:
	var hit_beat: float = current_beat
	var hit_offset = abs(hit_beat - dest_beat)

	if hit_offset <= micro_game.hit_timeframe: 	 _hit_notes += 1
	if hit_offset <= micro_game.perfect_timeframe: _perfect_notes += 1


## Called when _song ends
func _song_end() -> void:
	# TODO: add timer and save some info
	exit.emit()



## Reset game stats
func _reset_stats() -> void:
	_hit_notes = 0
	_perfect_notes = 0


func _play_sound( _sound ) -> void:
	pass


## Called when game is paused by the user
func _pause() -> void:
	get_tree().paused = true
	_player.set_wands_state(true)
	_song_player.pause()
	_show_menu(true)

## Called when game is resumed
func _unpause() -> void:
	get_tree().paused = false
	_player.set_wands_state(false)
	_song_player.play()
	_show_menu(false)



func _show_menu(state: bool) -> void:
	if state:
		_menu_panel.process_mode = Node.PROCESS_MODE_INHERIT
		_menu_panel.visible = true
		for obj in get_tree().get_nodes_in_group("hidden_in_menu"): obj.visible = false
			
	else:
		_menu_panel.process_mode = Node.PROCESS_MODE_DISABLED
		_menu_panel.visible = false
		for obj in get_tree().get_nodes_in_group("hidden_in_menu"): obj.visible = true



## Called when player pressed menu button
func _on_player_paused():
	if not game_paused: _pause()
	else:				_unpause()


func _on_menu_resume_pressed():
	if game_paused: _unpause()


func _on_menu_exit_pressed():
	get_tree().paused = false
	exit.emit()
