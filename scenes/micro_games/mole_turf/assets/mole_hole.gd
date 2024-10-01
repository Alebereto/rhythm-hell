extends Node3D

'''
Summons moles
'''

func _get_creep_height(): return $Model/Black.position.y
var _mole_peak_height = 1.0
const PEAK_OFFSET = -0.1

var _active_mole: Mole = null

@onready var _mole_root = $MoleRoot

@onready var _bonk_effect: GPUParticles3D = $BonkEffect
@onready var _creep_sound: AudioStreamPlayer3D = $CreepSound
@onready var _rise_sound: AudioStreamPlayer3D = $RiseSound

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


## Gets instantiated mole and time
func sprout(mole: Mole, time: float):

	# update mole variables
	mole.position.y = Mole.HIDDEN_HEIGHT
	mole.creep_height = _get_creep_height()
	mole.peak_height = _mole_peak_height
	mole.bonk_effect.connect(_make_bonk_effect)
	mole.creeped.connect(_on_creep)
	mole.risen.connect(_on_rise)

	_mole_root.add_child(mole)

	# Call mole.rise() when mole is ready
	if mole.is_node_ready(): mole.rise(time)
	else: mole.ready.connect(mole.rise.bind(time), CONNECT_ONE_SHOT)

func update_mole_peak(shoulder_height: float) -> void:
	_mole_peak_height = shoulder_height - Mole.HEAD_HEIGHT + PEAK_OFFSET

func kill_active_mole():
	_active_mole = null
	for child in _mole_root.get_children():
		child.queue_free()


func _make_bonk_effect(global_pos: Vector3, perfect: bool) -> void:
	_bonk_effect.global_position = global_pos
	if perfect: _bonk_effect.draw_pass_1.surface_get_material(0).albedo_color = Color.YELLOW
	else: _bonk_effect.draw_pass_1.surface_get_material(0).albedo_color = Color.WHITE
	if _bonk_effect.emitting: _bonk_effect.emitting = false
	else: _bonk_effect.emitting = true

func _on_creep() -> void:
	_creep_sound.play()

func _on_rise() -> void:
	_rise_sound.play()
