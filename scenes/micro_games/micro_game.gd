class_name MicroGame extends Node3D

'''
Base class for micro games
'''

## Emitted when note is hit
signal note_hit( perfect:bool )


var _timers_root: Node

# current bpm
var bpm: int = 100

func _beats_to_seconds(beats: float) -> float:
	return (beats / float(bpm)) * 60.0

var _player: Player = null

@export_group("Game settings")
# seconds timeframe that note needs to be hit at
@export_range(0,1) var hit_timeframe: float = 0.1
@export_range(0,1) var perfect_timeframe: float = 0.04

@export_group("Configurations")
# max seconds needed before start of note
@export_range(0, 10) var max_note_delay: float = 0
@export_range(0,10) var max_event_delay: float = 0



func _ready():
	# make root for note timers
	_timers_root = Node.new()
	add_child(_timers_root)


## Called by micro game when playing note
## Must override
func _play_note( _note: Globals.NoteInfo ): pass

## Called by micro game when playing event
## Must override
func _start_event( _event: Globals.EventInfo): pass



## Called by micro_game to get the time needed before note.s
## Must override
func _get_note_delay( _note: Globals.NoteInfo ): return 0

## Called by micro_game to get the time needed before note.s
## Must override
func _get_event_delay( _event: Globals.EventInfo ): return 0


## Gets called by game controller max_note_delay seconds
## before note start, adds note to queue.
func add_note_to_queue( note_info: Globals.NoteInfo ) -> void:
	var wait_time: float = max_note_delay - _get_note_delay(note_info)
	if wait_time <= 0: _play_note( note_info )
	else:
		# make timer
		var timer = Timer.new()
		timer.autostart = true
		timer.one_shot = true
		timer.wait_time = wait_time

		timer.timeout.connect( _play_note.bind( note_info ) ) # call _play_note of note when timer ends
		timer.timeout.connect((func(node): node.queue_free()).bind(timer)) # delete timer after timer ends

		_timers_root.add_child( timer )

## Gets called by game controller max_event_delay seconds
## before event start, adds event to queue.
func add_event_to_queue(event_info: Globals.EventInfo) -> void:
	var wait_time: float = max_event_delay - _get_event_delay(event_info)
	if wait_time <= 0: _start_event(event_info)
	else:
		# make timer
		var timer = Timer.new()
		timer.autostart = true
		timer.one_shot = true
		timer.wait_time = wait_time

		timer.timeout.connect( _start_event.bind( event_info ) ) # call _start_event with event when timer ends
		timer.timeout.connect((func(node): node.queue_free()).bind(timer)) # delete timer after timer ends

		_timers_root.add_child( timer )


## Gets called when replaying level.
## Should reset micro game to original state
func on_reset() -> void:
	_clear_timer_queue()

## Called by game_controller when setting the player.
## Can override to set link player controls to game
func set_player(player: Player) -> void:
	_player = player

## Clears all queued notes
func _clear_timer_queue() -> void:
	for timer in _timers_root.get_children():
		timer.queue_free()
