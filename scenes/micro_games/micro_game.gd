class_name MicroGame extends Node3D

'''
Base class for micro games
'''

## Emitted when note is hit, gets note destination beat
signal note_hit( dest_beat: float )
## Emitted when a note has been played
signal note_played
## Emitted when a note was missed
signal note_missed

## Emitted when playing a sonud
signal play_sound( sound )

var _note_timers_root: Node

var level: Level = null

var _player: Player = null

@export_group("Game settings")
# seconds timeframe that note needs to be hit
@export_range(0,1) var hit_timeframe: float = 0.3
@export_range(0,1) var perfect_timeframe: float = 0.1

@export_group("Configurations")
# max seconds needed before start of note
@export_range(0, 10) var max_note_delay: float = 0



func _ready():
	# make root for note timers
	_note_timers_root = Node.new()
	add_child(_note_timers_root)


## Gets called by game controller max_note_delay seconds
## before note start, adds note to queue.
func add_note_to_queue( note: Globals.NoteInfo ) -> void:
	var wait_time: float = max_note_delay - _get_note_delay(note)
	# make timer
	var timer = Timer.new()
	timer.timeout.connect( play_note.bind( note ) ) # call play_note of note when timer ends
	timer.timeout.connect((func(node): node.queue_free()).bind(timer)) # delete timer after timer ends
	timer.autostart = true
	timer.one_shot = true
	timer.wait_time = wait_time
	_note_timers_root.add_child( timer )


func _clear_note_queue() -> void:
	for timer in _note_timers_root.get_children():
		timer.queue_free()


## Called by micro_game to get playing note time.
## Must override
func _get_note_delay( _note: Globals.NoteInfo ): return 0


## Called by game_controller when playing note.
## Must override
func play_note( _note: Globals.NoteInfo ): pass

## Called by game_controller when setting the player.
## Can override to set link player controls to game
func set_player(player: Player) -> void:
	_player = player

