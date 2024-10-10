extends MicroGame

const DISTANCE_FROM_TARGET: float = 3	# Distance on z axis that objects spawn at from their target

const SHOULDER_OFFSET: float = 0.06

var _right_sword: Hand = null
var _left_sword: Hand = null

enum NoteID{LOWER, UPPER, BOTH}
enum EventID{ SKY_CHANGE=0 }

@onready var _targets: Array[Array] = [[$Objects/Targets/Up/t1, $Objects/Targets/Up/t2, $Objects/Targets/Up/t3, $Objects/Targets/Up/t4],
									   [$Objects/Targets/Down/t1, $Objects/Targets/Down/t2, $Objects/Targets/Down/t3, $Objects/Targets/Down/t4]]

@onready var _slice_objects_root: Node3D = $Objects/SliceObjects

var sky_tween: Tween
@onready var _sky_material: ProceduralSkyMaterial = $Objects/World/WorldEnvironment.environment.sky.sky_material
@export_color_no_alpha var _init_sky_color: Color = Color.WHITE

const SLICE_OBJECT_SCENE = preload("res://scenes/micro_games/slicer/assets/slice_object.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	_sky_material.sky_top_color = _init_sky_color

func _play_note( note: Globals.NoteInfo ):
	# Get info from note
	var col: int = note.layer - 1
	var delay: float = _beats_to_seconds(note.b - note.s)
	var right: bool = note.rotated
	var id = note.id

	# Check if note is valid
	if id > 2:
		push_warning("Invalid note id")
		id = 2
	if col >= _targets[0].size():
		push_warning("Invalid not layer")
		col = 0
	if delay <= 0:
		push_warning("Time must be greater than 0")
		delay = 0.5
	
	match id as NoteID:
		NoteID.LOWER: _spawn_slice_object(1, col, right, delay)
		NoteID.UPPER: _spawn_slice_object(0, col, right, delay)
		NoteID.BOTH:
			_spawn_slice_object(1, col, right, delay)
			_spawn_slice_object(0, col, right, delay)

func _start_event( event_info: Globals.EventInfo):
	match event_info.id:
		EventID.SKY_CHANGE:  _change_sky(event_info)
		

func _change_sky( event: Globals.EventInfo ) -> void:
	if sky_tween and sky_tween.is_running(): sky_tween.kill()
	sky_tween = create_tween()

	sky_tween.tween_property(_sky_material, "sky_top_color", event.color, event.delay)

func _get_note_delay( _note: Globals.NoteInfo ): return SliceObject.CREATE_TIME

func on_reset() -> void:
	super()
	for child in _slice_objects_root.get_children():
		child.queue_free()
	
	if sky_tween: sky_tween.kill()
	_sky_material.sky_top_color = _init_sky_color

func set_player(player: Player) -> void:
	super(player)
	_right_sword = player.set_right_hand(Globals.HAND.SWORD)
	_left_sword = player.set_left_hand(Globals.HAND.SWORD)

	# Set targets height
	$Objects/Targets.position.y = player.get_shoulder_height() + SHOULDER_OFFSET

	# Connect sword signals
	_right_sword.object_sliced.connect(_on_right_sword_object_sliced)
	_right_sword.object_shallow_sliced.connect(_on_right_sword_object_shallow_sliced)

	_left_sword.object_sliced.connect(_on_left_sword_object_sliced)
	_left_sword.object_shallow_sliced.connect(_on_left_sword_object_shallow_sliced)



func _create_slice_object(right: bool) -> SliceObject:
	var slice_object = SLICE_OBJECT_SCENE.instantiate()
	# init values
	slice_object.right = right
	slice_object.color = _right_sword.color if right else _left_sword.color
	
	return slice_object

func _spawn_slice_object(row: int, col: int, right: bool, delay: float):
	
	var slice_object: SliceObject = _create_slice_object(right)
	slice_object.delay = delay

	# Get target position
	var global_target_position: Vector3 = _targets[row][col].global_position
	slice_object.global_target_position = global_target_position

	# Get initial position
	var global_initial_position: Vector3 = Vector3(global_target_position)
	global_initial_position.z -= DISTANCE_FROM_TARGET
	slice_object.transform.origin = global_initial_position

	_slice_objects_root.add_child(slice_object)


## Called when sword slices SliceObject
func _on_sword_slice_object( body: SliceObject, correct_sword: bool ):
	var dest_difference = body.get_destination_difference()
	if dest_difference > hit_timeframe or not correct_sword:
		body.on_break()
	else:
		var perfect = true if dest_difference <= perfect_timeframe else false
		body.on_slice(perfect)
		note_hit.emit(perfect)

## Called when sword slices SliceObject incorrectly
func _on_sword_shallow_slice_object( body: SliceObject ):
	body.on_break()


# player inputs ================================================

func _on_right_sword_object_sliced( body: SliceObject ):

	var correct_sword = true if body.right else false
	_on_sword_slice_object(body, correct_sword)

func _on_right_sword_object_shallow_sliced( body: SliceObject ):
	_on_sword_shallow_slice_object(body)

func _on_left_sword_object_sliced( body: SliceObject ):

	var correct_sword = false if body.right else true
	_on_sword_slice_object(body, correct_sword)

func _on_left_sword_object_shallow_sliced( body: SliceObject ):
	_on_sword_shallow_slice_object(body)


func _on_death_box_body_entered(body:Node3D):
	if body is SliceObject:
		body.queue_free()
