class_name GameController extends Node3D

'''
Base class for micro-games
'''

# Path to song directory
@export_dir var song_path: String

# Get audio player
@onready var audio_player = $AudioStreamPlayer

# Controls song playing and contains song information
var song: Song
# OpenXR interface
var interface: XRInterface

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

## Starts song from given time
func _start_song(time: float = 0) -> void:
	# make timers
	pass

func _pause() -> void:
	pass

func _resume() -> void:
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	song = Song.new(song_path, audio_player)
	_init_vr()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
