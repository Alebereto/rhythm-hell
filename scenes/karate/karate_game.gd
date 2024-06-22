extends Node3D


## Emitted when note is hit, gets note destination beat
signal note_hit(dest_beat: float)
## Emitted when playing sonud
signal play_sound( sound )

var song: Song = null

var _player: Player = null


@onready var _projectiles_root: Node3D = $Objects/Projectiles

@export_group("Cannon")
@export var _cannon: Node3D

# Projectiles
const _projectile_scenes = [preload("res://scenes/karate/assets/projectiles/projectile.tscn")]

# Sounds
var HitSound = preload("res://audio/sounds/hit.wav")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func play_note(note: Dictionary):

	# Get fire time
	var fire_time = song.beats_to_seconds(note["b"] - note["s"])
	if fire_time <= 0:
		push_warning("Cannot fire in time < 0!")
		fire_time = 0.1

	# Get projectile id
	var id = note["id"]
	if id >= len(_projectile_scenes):
		push_warning("Projectile with id: %d does not exist!" %id)
		id = 0

	# Create projectile
	var projectile: Projectile = _create_projectile(id)
	projectile.destination_beat = note["b"]

	# Fire projectile
	_cannon.fire(projectile, fire_time)	# TODO: have two cannons and pick according to note info


func set_player(player: Player) -> void:
	_player = player
	_player.right_hand_entered_body.connect(_on_player_right_hand_entered_body)



func _create_projectile(id: int) -> Projectile:
	var projectile: Projectile = _projectile_scenes[id].instantiate()
	_projectiles_root.add_child(projectile)
	projectile.hit.connect(_on_note_hit, ConnectFlags.CONNECT_ONE_SHOT)

	return projectile


func _on_note_hit(dest_beat: float) -> void:
	note_hit.emit(dest_beat)




func _on_player_right_hand_entered_body(body):
	if not (body is Projectile): return
	# body is a projectile ======

	body.apply_impulse(Vector3(0,0,-10))

