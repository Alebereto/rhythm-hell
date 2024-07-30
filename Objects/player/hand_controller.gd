extends XRController3D

signal trigger_pressed
signal menu_button_pressed

@export_color_no_alpha var _hand_color: Color = Color.WHITE

@onready var _wand = $Wand
var _using_wand = true

var _hand = null

func _get_hand(): return _hand
var hand: get = _get_hand


# Called when the node enters the scene tree for the first time.
func _ready():
	_wand.set_color(_hand_color)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


## Instantiates and adds hand to controller
func set_hand( hand_scene: PackedScene ):

	# TODO: clear hand if already present ===

	_hand = hand_scene.instantiate()
	hand.color = _hand_color
	add_child(hand)

	if _using_wand: toggle_wand()

	return hand


func _on_controller_pressed_button(button_name):
	match button_name:
		"trigger_click": trigger_pressed.emit()
		"menu_button":	 menu_button_pressed.emit()


func toggle_wand() -> void:
	if _using_wand:
		_wand.visible = false
		_wand.process_mode = Node.PROCESS_MODE_DISABLED
		_using_wand = false
	else:
		_wand.visible = true
		_wand.process_mode = Node.PROCESS_MODE_ALWAYS
		_using_wand = true
