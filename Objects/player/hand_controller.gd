extends XRController3D

signal trigger_pressed
signal menu_button_pressed


# Color of hand
@export_color_no_alpha var _hand_color: Color = Color.WHITE
# Wand
@onready var _wand = $Wand

# true if using wand
var _using_wand = true
# ref to current hand
var _hand = null

# Getters
var is_using_wand:
	get: return _using_wand
var hand:
	get: return _hand
var wand:
	get: return _wand
# true if controller is currently clicking
var clicking: bool:
	get: return is_button_pressed("trigger")


# Called when the node enters the scene tree for the first time.
func _ready():
	_wand.set_color(_hand_color)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

## Set whether player is holding wands or not
func set_wand_state(state: bool) -> void:
	if state:
		_wand.visible = true
		_wand.process_mode = Node.PROCESS_MODE_ALWAYS
		_using_wand = true
		if _hand != null:
			_hand.visible = false
			_hand.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		if _using_wand: _wand.unfocus()
		_wand.visible = false
		_wand.process_mode = Node.PROCESS_MODE_DISABLED
		_using_wand = false
		if _hand != null:
			_hand.visible = true
			_hand.process_mode = Node.PROCESS_MODE_INHERIT

## Instantiates and adds hand to controller
func set_hand( hand_scene: PackedScene ):

	# TODO: clear hand if already present ===

	_hand = hand_scene.instantiate()
	hand.color = _hand_color
	add_child(hand)

	if _using_wand: set_wand_state(false)

	return hand


func vibrate() -> void:
	trigger_haptic_pulse("haptic", 0, 0.1, 0.1, 0)


func _on_button_pressed(button_name):
	match button_name:
		"trigger_click":
			trigger_pressed.emit()
			if _using_wand: _wand.on_button(true)
		"menu_button":	 menu_button_pressed.emit()

func _on_button_released(button_name):
	match button_name:
		"trigger_click":
			if _using_wand: _wand.on_button(false)
