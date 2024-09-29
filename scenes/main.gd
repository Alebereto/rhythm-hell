extends Node


const MainMenuScene: PackedScene = preload("res://scenes/main_menu/main_menu.tscn")
const GameControllerScene: PackedScene = preload("res://scenes/micro_games/game_controller.tscn")

var _xr_interface: XRInterface

var _current_scene: Node = null	# The current scene that player is in


# Called when the node enters the scene tree for the first time.
func _ready():
	_init_vr()
	await _load_main_menu()


func _load_main_menu( load_data = null ):
	_close_scene()

	# create main menu scene
	var main_menu = MainMenuScene.instantiate()
	_current_scene = main_menu

	main_menu.load_data = load_data
	add_child(main_menu)
	if not main_menu.is_node_ready(): await main_menu.ready

	main_menu.level_played.connect(_load_game_controller, ConnectFlags.CONNECT_ONE_SHOT)


func _load_game_controller( level ):
	_close_scene()

	# create game scene
	var game_controller = GameControllerScene.instantiate()
	_current_scene = game_controller
	add_child(game_controller)
	if not game_controller.is_node_ready(): await game_controller.ready

	game_controller.exit.connect(_load_main_menu, ConnectFlags.CONNECT_ONE_SHOT)

	# load level
	await game_controller.load_level( level )




func _close_scene() -> void:
	# Remove current scene if present
	if _current_scene == null: return

	# maybe call some function on exit here ======
	_current_scene.queue_free()
	_current_scene = null



func _init_vr():
	_xr_interface = XRServer.find_interface("OpenXR")
	if _xr_interface and _xr_interface.is_initialized():
		print("OpenXR instantiated successfully.")

		# Make sure v-sync is off, v-sync is handled by OpenXR
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		get_viewport().use_xr = true
	else:
		# couldn't start OpenXR.
		print("OpenXR not instantiated!")

