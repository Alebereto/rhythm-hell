extends MicroGame

const MOLE_HOLE_COUNT = 4

var _right_hammer = null
var _left_hammer = null

const MOLE_SCENES = [preload("res://scenes/micro_games/mole_turf/assets/mole.tscn")]


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

## Called by micro game when playing note
func _play_note( _note: Globals.NoteInfo ):
	# Get mole hole
	var hole_idx = _note.layer - 1
	if hole_idx >= MOLE_HOLE_COUNT:
		push_warning("Invalid Mole Hole")
		hole_idx = 0
	var mole_hole = _mole_holes[hole_idx]
	
	# Get mole id
	var mole_id = _note.id
	if mole_id >= len(MOLE_SCENES):
		push_warning("Invalid mole id")
		mole_id = Globals.MOLE_TYPES.NORMAL

	var mole = _create_mole(MOLE_SCENES[mole_id])

	mole_hole.sprout(mole)


func _create_mole(mole_scene: PackedScene):
	var mole = mole_scene.instantiate()
	
	return mole

## Called by micro_game to get the time needed before note.s
func _get_note_delay( _note: Globals.NoteInfo ):
	return 0

