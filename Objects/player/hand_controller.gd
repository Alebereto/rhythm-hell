extends XRController3D


signal trigger_pressed
signal menu_button_pressed


# Color of hand
@export_color_no_alpha var _hand_color: Color = Color.WHITE
func get_hand_color() -> Color: return _hand_color

# Wand
@onready var _wand: Wand = $Wand
var _using_wand = true # true if using wand

# ref to current hand
var _hand: Hand = null

# true if controller emits inputs
var _inputs_active = true

# Getters
func is_using_wand(): return _using_wand
func get_hand(): return _hand
func get_wand(): return _wand
# true if controller is currently clicking
func is_clicking(): return is_button_pressed("trigger")



# Called when the node enters the scene tree for the first time.
func _ready():
	_wand.set_color(_hand_color)



## Set whether player is holding wands or not
func set_wand_state(state: bool) -> void:
	# Turn wand on
	if state:
		# if player has hand, deactivate hand
		if _hand != null:
			_hand.visible = false
			_hand.process_mode = Node.PROCESS_MODE_DISABLED
		# activate wand
		_wand.visible = true
		_wand.process_mode = Node.PROCESS_MODE_ALWAYS
		_using_wand = true
		
	# Turn wand off
	else:
		# deactivate wand
		if _using_wand: _wand.unfocus()
		_wand.visible = false
		_wand.process_mode = Node.PROCESS_MODE_DISABLED
		_using_wand = false
		# if player has hand, activate hand
		if _hand != null:
			_hand.visible = true
			_hand.process_mode = Node.PROCESS_MODE_INHERIT

## Instantiates and adds hand to controller
func set_hand( hand_scene: PackedScene ):

	if _hand != null: _hand.queue_free()
	# TODO: maybe not clear but switch between hands

	_hand = hand_scene.instantiate()
	_hand.vibrate.connect(vibrate)
	_hand.color = _hand_color
	add_child(_hand)

	if _using_wand: set_wand_state(false)

	return _hand


func vibrate() -> void:
	trigger_haptic_pulse("haptic", 0, 0.1, 0.1, 0)


func stop_inputs():
	_inputs_active = false
	if _using_wand: _wand.laser_off()

func enable_inputs():
	_inputs_active = true



# inputs ==========================

func _on_button_pressed(button_name):
	if not _inputs_active: return
	match button_name:
		"trigger_click":
			trigger_pressed.emit()
			if _using_wand: _wand.on_button(true)
		"menu_button":	 menu_button_pressed.emit()

func _on_button_released(button_name):
	if not _inputs_active: return
	match button_name:
		"trigger_click":
			if _using_wand: _wand.on_button(false)
