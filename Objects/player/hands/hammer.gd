extends Node3D

signal mole_bonked( hammer, mole: Mole )
signal mole_tapped( hammer, mole: Mole )
signal vibrate

@onready var _bonk_sound: AudioStreamPlayer3D = $BonkSound
@onready var _bonk_perfect_sound: AudioStreamPlayer3D = $BonkPerfectSound

var color: Color = Color.WHITE

const _downwards = Vector3(0,-1,0)
const _max_positions: int = 10
var _last_position_queue: Globals.Queue

@export_range(0,1) var _bonk_threshold: float = 0.1

# Called when the node enters the scene tree for the first time.
func _ready():
	_set_color()
	_last_position_queue = Globals.Queue.new(_max_positions)

# Called every physics frame.
func _physics_process(_delta):
	_last_position_queue.add(global_position)



func _set_color():
	$Model/Blunt.get_active_material(0).albedo_color = color


## Checks if hammer is currently fast enough to bonk a mole
func _is_bonking_speed() -> bool:
	var last_pos = _last_position_queue.peek()
	if last_pos == null: return false

	var mag = _downwards.dot(global_position - last_pos)

	return mag >= _bonk_threshold


func play_bonk_sound() -> void: _bonk_sound.play()
func play_bonk_perfect_sound() -> void: _bonk_perfect_sound.play()

# Inputs ======================

func _on_area_entered(area: Area3D):
	var parent = area.get_parent()

	if parent is Mole and parent.is_active():
		if _is_bonking_speed():
			mole_bonked.emit(self, parent)
		else:
			mole_tapped.emit(self, parent)
