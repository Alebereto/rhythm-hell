class_name Player extends Node3D

var interface: XRInterface
@onready var button_pressed: Signal = $RightController.button_pressed


func _init_vr():
	interface = XRServer.find_interface("OpenXR")
	if interface and interface.is_initialized():
		print("OpenXR instantiated successfully.")
		var vp : Viewport = get_viewport()
		
		# Enable xr on viewport
		vp.use_xr = true
		
		# Make sure v-sync is off, v-sync is handled by OpenXR
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	
	else:
		# couldn't start OpenXR.
		print("OpenXR not instantiated!")
		# get_tree().quit()

# Called when the node enters the scene tree for the first time.
func _ready():
	_init_vr()

