extends MicroGame


const CANNON_DELAY := 0.3


@export_group("Cannons")
@export var _right_cannon: Node3D
@export var _left_cannon: Node3D

# Projectiles
const _projectile_scenes: Array[PackedScene] = [preload("res://scenes/karate/assets/projectiles/rock.tscn"),
												preload("res://scenes/karate/assets/projectiles/barrel.tscn")]

# Sounds
var HitSound = preload("res://audio/sounds/hit.wav")


# Called when the node enters the scene tree for the first time.
func _ready():
	super()

func set_player(player: Player) -> void:
	super(player)

	# set karate hands

	# connect hand signals
	# _player.right_hand_entered_body.connect(_on_player_right_hand_entered_body)



func play_note(note: Dictionary):

	var cannon = _left_cannon if note["rotated"] else _right_cannon # get cannon

	# Create projectile
	var projectile: Projectile = _create_projectile( note )

	# Get fire time
	var fire_time = song.beats_to_seconds(note["b"] - note["s"])
	if fire_time <= 0:
		push_warning("Cannot fire in time <= 0!")
		fire_time = 0.1
	
	# Fire projectile
	await cannon.fire(projectile, fire_time)


func _get_note_delay( _note ): return CANNON_DELAY


func _create_projectile( note ) -> Projectile:
	# Get projectile id
	var id = note["id"]
	if id >= len(_projectile_scenes):
		push_warning("Projectile with id: %d does not exist!" %id)
		id = 0

	var projectile: Projectile = _projectile_scenes[id].instantiate()
	projectile.hit.connect(_on_note_hit, ConnectFlags.CONNECT_ONE_SHOT)
	projectile.destination_beat = note["b"]

	return projectile


func _on_note_hit(dest_beat: float) -> void:
	note_hit.emit(dest_beat)




func _on_player_right_hand_entered_body(body):
	if not (body is Projectile): return
	# body is a projectile ======

	body.apply_impulse(Vector3(0,0,-10))

