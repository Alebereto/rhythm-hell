class_name GameController extends Node3D

'''
Plays levels by interacting with micro games
'''

const LEVEL_DELAY = 1.5

# Emitted when exiting level
signal exit( exit_data: Globals.MainMenuLoadData )

# TODO: load depending on which games are present in level
const MICRO_GAME_SCENES = [ preload("res://scenes/micro_games/karate/karate.tscn"),
							preload("res://scenes/micro_games/mole_turf/mole_turf.tscn"),
							preload("res://scenes/micro_games/slicer/slicer.tscn")]

# Get Player reference
@onready var _player: Player = $Player
# Get song player
@onready var _song_player: SongPlayer = $SongPlayer
# Get pause menu panel
@onready var _menu_panel: VRUI = $MenuPanel


# True when level has ended and leaving level
var _ended: bool = false

# contains level information
var _level: Level
# micro game scene reference
var _micro_game: MicroGame = null

# index of next note to be played from _level.note_list
var _next_note_idx: int = 0
# index of next event to be played from _level.event_list
var _next_event_idx: int = 0


# Some values
func _is_paused(): return get_tree().paused
func _get_current_second() -> float: return _song_player.current_second
func _get_current_beat() -> float: return _level.seconds_to_beats(_get_current_second())



## Loads level
func load_level(level: Level) -> void:

	# Load level info
	_level = level
	_song_player.load_song( _level.song_audio_path, _level.length )	# load audio to song player

	# Load micro game
	await _load_micro_game( level.micro_game_id )

	await _start_level(0, LEVEL_DELAY)
	

# Called when the node enters the scene tree for the first time.
func _ready():
	_player.paused.connect(_on_player_paused)
	_player.fade_in()



# Called every physics frame.
func _physics_process(_delta):
	if not _is_paused() and not _ended:
		_check_next_note()
		_check_next_event()
		_check_song_end()


## If song got to next note, play it and set new next note
func _check_next_note() -> void:
	# if next note is available
	if  _next_note_idx < _level.note_list.size():
		
		var next_note: Globals.NoteInfo = _level.note_list[_next_note_idx] # get next note
		var start_note_time: float = _level.beats_to_seconds(next_note.s) - _micro_game.max_note_delay

		# if current second is greater or equal to the start second of the next note, queue it
		if _get_current_second() >= start_note_time:
			_queue_note(next_note)
			_next_note_idx += 1

func _check_next_event() -> void:
	# if next note is available
	if  _next_event_idx < _level.event_list.size():
		
		var next_event: Globals.EventInfo = _level.event_list[_next_event_idx] # get next event
		var start_event_time: float = _level.beats_to_seconds(next_event.s) - _micro_game.max_event_delay

		# if current second is greater or equal to the start second of the next note, queue it
		if _get_current_second() >= start_event_time:
			_queue_event(next_event)
			_next_event_idx += 1

func _check_song_end() -> void:
	if _get_current_second() >= _level.length: _on_level_end()



## Loads micro game
func _load_micro_game( game_id: Globals.MICRO_GAMES ) -> void:
	# unload micro game if exists
	if _micro_game != null: _micro_game.queue_free()

	# load micro game
	_micro_game = MICRO_GAME_SCENES[ game_id ].instantiate()
	# Connect signals
	_micro_game.note_hit.connect( _on_note_hit )
	# Init values
	_micro_game.bpm = _level.initial_bpm

	add_child( _micro_game )
	if not _micro_game.is_node_ready(): await _micro_game.ready

	# set player refrence and init some attributes in micro game
	_micro_game.set_player(_player)
	

## Starts level from given time
func _start_level(time: float = 0, delay: float = 1.5) -> void:
	# set initial stats for level
	_song_player.seek(time)
	
	# reset state
	_micro_game.on_reset()
	_reset_stats()

	# find next note index
	if time == 0: _next_note_idx = 0
	else: 		  _next_note_idx = _level.find_next_note_idx(time)

	# Wait before level start 'delay' seconds
	if delay > 0: await get_tree().create_timer(delay, false).timeout
	# if statement is for desync problems
	if not _song_player.is_playing(): _song_player.play()




## Adds next note to queue
func _queue_note( note_info: Globals.NoteInfo ) -> void:
	_micro_game.add_note_to_queue(note_info)

## Adds next event to queue
func _queue_event(event_info: Globals.EventInfo) -> void:
	_micro_game.add_event_to_queue(event_info)

## Gets called when payer hits note
func _on_note_hit(perfect: bool) -> void:
	_level.hit_notes += 1
	if perfect: _level.perfect_notes += 1



## Reset game stats
func _reset_stats() -> void:
	_level.hit_notes = 0
	_level.perfect_notes = 0

func _replay():
	_ended = false
	_show_menu(false)
	_player.set_wands_state(false)
	_player.fade_in()
	_player.enable_inputs()

	_start_level(0, LEVEL_DELAY)


# Level end ======================

## Collect data when leaving game scene
func _collect_game_data( aborted: bool ) -> Dictionary:
	var data = {
		"level": _level,
		"aborted": aborted,}
	return data

## Exits level and switches to main menu
func _switch_to_main_menu( aborted: bool = false ) -> void:

	var data = _collect_game_data(aborted)
	var menu_data = Globals.MainMenuLoadData.new(Globals.MENU_NAME.RESULTS_SCREEN, data)
	exit.emit( menu_data )

## Called when level ends
func _on_level_end() -> void:
	const TIME_TO_FADE = 1
	if _ended: return
	_ended = true
	_player.stop_inputs()
	_player.fade_out( TIME_TO_FADE, _switch_to_main_menu )



# Pausing =============

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


## Shows pause menu
func _show_menu(state: bool) -> void:
	if state:
		_menu_panel.process_mode = Node.PROCESS_MODE_INHERIT
		_menu_panel.visible = true
		for obj in get_tree().get_nodes_in_group(Globals.HIDDEN_OBJECTS_GROUP_NAME): obj.visible = false
			
	else:
		_menu_panel.process_mode = Node.PROCESS_MODE_DISABLED
		_menu_panel.visible = false
		for obj in get_tree().get_nodes_in_group(Globals.HIDDEN_OBJECTS_GROUP_NAME): obj.visible = true



# Input methods =================================

## Called when player pressed menu button
func _on_player_paused():
	if not _is_paused(): _pause()
	else:				_unpause()


func _on_menu_resume_pressed():
	if _is_paused(): _unpause()


func _on_menu_exit_pressed():
	_ended = true
	_player.stop_inputs()
	get_tree().paused = false
	_player.fade_out( 0.3, _switch_to_main_menu.bind(true) )


func _on_menu_replay_pressed():
	_ended = true
	_player.stop_inputs()
	get_tree().paused = false
	_player.fade_out( 0.3, _replay )
