extends MicroGame


const CANNON_DELAY := 0.3

var _right_puncher = null
var _left_puncher = null


@export var _projectiles_root: Node3D
@export var _target: Node3D

@export_group("Cannons")
@export var _right_cannon: Node3D
@export var _left_cannon: Node3D


var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _gravity_vector: Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity_vector")

# Projectiles
const _projectile_scenes: Array[PackedScene] = [preload("res://scenes/micro_games/karate/assets/projectiles/rock.tscn"),
												preload("res://scenes/micro_games/karate/assets/projectiles/barrel.tscn")]

# Sounds
var HitSound = preload("res://audio/sounds/hit.wav")


# Called when the node enters the scene tree for the first time.
func _ready():
	super()

func set_player(player: Player) -> void:
	super(player)

	# Set player hands and get refrences to them
	_right_puncher = player.set_right_hand( Globals.HAND.PUNCHER )
	_left_puncher = player.set_left_hand( Globals.HAND.PUNCHER )

	# connect hand signals
	_right_puncher.projectile_hit.connect(_on_right_puncher_hit_projectile)
	_left_puncher.projectile_hit.connect(_on_left_puncher_hit_projectile)
	_right_puncher.projectile_touched.connect(_on_right_puncher_touch_projectile)
	_left_puncher.projectile_touched.connect(_on_left_puncher_touch_projectile)



func _play_note(note: Globals.NoteInfo):

	var cannon = _left_cannon if note.rotated else _right_cannon # get cannon

	# Create projectile
	var projectile: Projectile = _create_projectile( note )

	# Get fire time
	var fire_time = _beats_to_seconds(note.b - note.s)
	if fire_time <= 0:
		push_warning("Cannot fire in time <= 0!")
		fire_time = 0.1
	
	# Fire projectile
	await cannon.fire(projectile, fire_time)
	note_played.emit()


func _get_note_delay( _note ): return CANNON_DELAY


func _create_projectile( note: Globals.NoteInfo ) -> Projectile:
	# Get projectile id
	var id = note.id
	if id >= len(_projectile_scenes):
		push_warning("Projectile with id: %d does not exist!" %id)
		id = 0

	var projectile: Projectile = _projectile_scenes[id].instantiate()
	projectile.destination_beat = note.b

	return projectile





func _on_right_puncher_hit_projectile( projectile: Projectile ) -> void:
	_on_hit_projectile(projectile)

func _on_left_puncher_hit_projectile( projectile: Projectile ) -> void:
	_on_hit_projectile(projectile)

func _on_hit_projectile( projectile: Projectile) -> void:
	projectile.on_hit()
	note_hit.emit()
	# if projectile was a barrel
	if projectile.id == 1: _summon_from_barrel( projectile )
		

func _on_right_puncher_touch_projectile( projectile: Projectile ) -> void:
	_on_touch_projectile(projectile)

func _on_left_puncher_touch_projectile( projectile: Projectile ) -> void:
	_on_touch_projectile(projectile)

func _on_touch_projectile( projectile: Projectile ) -> void:
	projectile.on_touch()
	note_missed.emit()


func _calculate_impulse(projectile: Projectile, destination: Node3D, travel_time: float) -> Vector3:

	var impulse: Vector3 = (destination.global_position - projectile.global_position) / travel_time
	impulse -= _gravity_vector * _gravity * 0.5 * travel_time

	impulse /= projectile.mass

	return impulse

func _summon_from_barrel( barrel: Projectile):
	const BEAT_DELAY = 1
	var travel_time = _beats_to_seconds(BEAT_DELAY)

	var projectile_scene: PackedScene = barrel.contained_projectile
	var contained_proj: Projectile = projectile_scene.instantiate()

	contained_proj.destination_beat = barrel.destination_beat + BEAT_DELAY
	contained_proj.position = barrel.position
	contained_proj.position.y += 0.6

	_projectiles_root.add_child(contained_proj)
	var impulse = _calculate_impulse( contained_proj, _target, travel_time )
	var torque = Vector3(1,2,2)	# TODO: make random vector

	contained_proj.apply_impulse(impulse)
	contained_proj.apply_torque_impulse(torque)
