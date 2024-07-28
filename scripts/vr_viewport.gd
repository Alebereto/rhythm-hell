extends SubViewport

var _xr_interface: XRInterface

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _init_vr():
	_xr_interface = XRServer.find_interface("OpenXR")
	if _xr_interface and _xr_interface.is_initialized():
		print("OpenXR instantiated successfully.")

		# Make sure v-sync is off, v-sync is handled by OpenXR
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	
	else:
		# couldn't start OpenXR.
		print("OpenXR not instantiated!")

