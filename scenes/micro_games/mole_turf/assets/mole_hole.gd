extends Node3D

'''
Summons moles
'''

var player_height: float # needed to determine sprout height
func _get_init_mole_height(): return $Model/Black.position.y
func _get_mole_peak_height(): return 1.03

var _active_tween

@onready var _mole_root = $MoleRoot

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func sprout(mole: Mole, time: float):
	mole.position.y = -1
	_mole_root.add_child(mole)
	_active_tween = create_tween()
	_active_tween.tween_property(mole, "position:y", _get_init_mole_height(), Mole.CREATE_TIME)
	# call method to activate mole
	_active_tween.tween_property(mole, "position:y", _get_mole_peak_height(), Mole.RISE_TIME).set_delay(time - Mole.RISE_TIME)
	_active_tween.tween_property(mole, "position:y", -1, Mole.LOWER_TIME).set_delay(Mole.UP_TIME)
