extends Node3D

signal level_played( level )


@onready var player: Player = $Player


var load_data = null

# menu panels
@onready var _main_menu_panel: VRUI = $Panels/Main
@onready var _custom_levels_panel: VRUI = $Panels/CustomLevels
@onready var _results_screen_panel: VRUI = $Panels/Results
const PANEL_ANIMATION_TIME: float = 0.4

@onready var _results_control = $Panels/Results/SubViewport/ResultsPanel

# Called when the node enters the scene tree for the first time.
func _ready():
	if not load_data is Globals.MainMenuLoadData: load_data = Globals.MainMenuLoadData.new()
	_load_state()
	player.fade_in()


func _switch_to_level( level ) -> void:
	level_played.emit(level)


func _play_level( level: Level ):
	const FADE_TIME = 0.3
	player.stop_inputs()
	player.fade_out( FADE_TIME, _switch_to_level.bind(level) )


func _exit_game() -> void:
	# TODO: maybe send signal to main and have main exit
	get_tree().quit()



func _load_state():
	match load_data.get_menu_name():
		Globals.MENU_NAME.MAIN:
			_set_main_menu_panel_state(true, false)
		Globals.MENU_NAME.CUSTOM_LEVELS:
			_set_custom_levels_panel_state(true, false)
		Globals.MENU_NAME.RESULTS_SCREEN:
			_results_control.load(load_data)
			_set_results_screen_panel_state(true, false)



# switching panel shinanigans =========================

func _set_panel_state(panel:VRUI, panel_visible:bool, do_tween:bool, dest_pos: Vector3):

	var panel_transparacy: float

	# get properties
	if panel_visible:
		panel.process_mode = Node.PROCESS_MODE_INHERIT
		panel_transparacy = 1.0
	else:
		panel.process_mode = Node.PROCESS_MODE_DISABLED
		panel_transparacy = 0
	
	# set properties
	if do_tween:
		var tween: Tween = create_tween()
		tween.tween_property(panel, "transparacy", panel_transparacy, PANEL_ANIMATION_TIME)
		tween.parallel().tween_property(panel, "position", dest_pos, PANEL_ANIMATION_TIME)
	else:
		panel.transparacy = panel_transparacy
		panel.position = dest_pos


func _set_main_menu_panel_state(panel_visible: bool, do_tween = true):
	const VIS_POSITION = Vector3(0, 1.5, -4)
	const INVIS_POSITION = Vector3(-6.5, 1.5, -4)
	var pos = VIS_POSITION if panel_visible else INVIS_POSITION

	_set_panel_state(_main_menu_panel, panel_visible, do_tween, pos)

func _set_custom_levels_panel_state(panel_visible: bool, do_tween = true):
	const VIS_POSITION = Vector3(0, 1.5, -4)
	const INVIS_POSITION = Vector3(6.5, 1.5, -4)
	var pos = VIS_POSITION if panel_visible else INVIS_POSITION

	_set_panel_state(_custom_levels_panel, panel_visible, do_tween, pos)

func _set_results_screen_panel_state(panel_visible: bool, do_tween = true):
	const VIS_POSITION = Vector3(0, 1.5, -4)
	const INVIS_POSITION = Vector3(0, 7, -4)
	var pos = VIS_POSITION if panel_visible else INVIS_POSITION

	_set_panel_state(_results_screen_panel, panel_visible, do_tween, pos)


# Input methods ========================================


# Main menu panel ====================

func _on_main_panel_custom_levels_pressed():
	_set_main_menu_panel_state(false)
	_set_custom_levels_panel_state(true)


func _on_main_panel_exit_pressed():
	_exit_game()


# Custom songs panel =================

func _on_level_played( level: Level ):
	_play_level(level)


func _on_custom_levels_panel_back_pressed():
	_set_custom_levels_panel_state(false)
	_set_main_menu_panel_state(true)


# Results panel =========================

func _on_results_panel_continue_pressed():
	_set_results_screen_panel_state(false)
	_set_custom_levels_panel_state(true)


func _on_results_panel_restart_pressed(level:Level):
	_play_level(level)
