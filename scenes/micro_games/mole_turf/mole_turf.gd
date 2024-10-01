extends MicroGame

var _right_hammer = null
var _left_hammer = null

const MOLE_SCENES = [preload("res://scenes/micro_games/mole_turf/assets/moles/normal_mole.tscn"),
					 preload("res://scenes/micro_games/mole_turf/assets/moles/quick_mole.tscn"),
					 preload("res://scenes/micro_games/mole_turf/assets/moles/slow_mole.tscn")]


@onready var _mole_holes = [$Objects/MoleHoles/Hole1,
							$Objects/MoleHoles/Hole2,
							$Objects/MoleHoles/Hole3,
							$Objects/MoleHoles/Hole4]

func _ready():
	super()

func set_player(player: Player):
	super(player)
	# Set player hands and get refrences to them
	_right_hammer = player.set_right_hand( Globals.HAND.HAMMER )
	_left_hammer = player.set_left_hand( Globals.HAND.HAMMER )

	_right_hammer.mole_bonked.connect(_on_right_hammer_bonked_mole)
	_left_hammer.mole_bonked.connect(_on_left_hammer_bonked_mole)

	_right_hammer.mole_tapped.connect(_on_right_hammer_tapped_mole)
	_left_hammer.mole_tapped.connect(_on_left_hammer_tapped_mole)

	for mole_hole in _mole_holes:
		mole_hole.update_mole_peak(player.get_shoulder_height())

## Called by micro game when playing note
func _play_note( _note: Globals.NoteInfo ):
	# Get mole hole
	var hole_idx = _note.layer - 1
	if hole_idx >= _mole_holes.size():
		push_warning("Invalid Mole Hole")
		hole_idx = 0
	var mole_hole = _mole_holes[hole_idx]
	
	# Get mole id
	var mole_id = _note.id
	if mole_id >= len(MOLE_SCENES):
		push_warning("Invalid mole id")
		mole_id = Globals.MOLE_TYPES.NORMAL

	var mole = _create_mole(mole_id)
	var sprout_time = _beats_to_seconds(_note.b - _note.s)

	mole_hole.sprout(mole, sprout_time)


func _create_mole(mole_id) -> Mole:
	var mole = MOLE_SCENES[mole_id].instantiate()
	return mole

## Called by micro_game to get the time needed before note.s
func _get_note_delay( _note: Globals.NoteInfo ):
	return Mole.CREATE_TIME

func on_reset() -> void:
	super()
	for mole_hole in _mole_holes:
		mole_hole.kill_active_mole()


## Called when hammer bonks active mole
func _on_hammer_bonk_mole( mole: Mole ):
	var dest_difference = mole.get_destination_difference()
	if dest_difference > hit_timeframe:
		mole.on_tap()
	else:
		var perfect = true if dest_difference <= perfect_timeframe else false
		note_hit.emit(perfect)
		mole.on_bonk(perfect)

## Called when hammer taps active mole
func _on_hammer_tap_mole(mole: Mole):
	mole.on_tap()

# Inputs =====================================

func _on_right_hammer_bonked_mole(mole: Mole):
	_on_hammer_bonk_mole(mole)

func _on_left_hammer_bonked_mole(mole: Mole):
	_on_hammer_bonk_mole(mole)

func _on_right_hammer_tapped_mole(mole: Mole):
	_on_hammer_tap_mole(mole)

func _on_left_hammer_tapped_mole(mole: Mole):
	_on_hammer_tap_mole(mole)
