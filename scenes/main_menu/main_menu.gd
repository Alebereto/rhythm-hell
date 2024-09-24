extends Node3D

signal level_played( level )


@onready var player: Player = $Player


# menu panels
@onready var _main_menu_panel: VRUI = $Panels/Main
@onready var _custom_levels_panel: VRUI = $Panels/CustomLevels
const PANEL_ANIMATION_TIME: float = 0.4


# Called when the node enters the scene tree for the first time.
func _ready():
	player.fade_in()


func _switch_to_level( level ) -> void:
	level_played.emit(level)


func _exit_game() -> void:
	# TODO: maybe send signal to main and have main exit
	get_tree().quit()



# switching panel shinanigans =========================

func _show_main_panel() -> void:
	_main_menu_panel.process_mode = Node.PROCESS_MODE_INHERIT

	var tween: Tween = create_tween()
	tween.tween_property(_main_menu_panel, "transparacy", 1.0, PANEL_ANIMATION_TIME)
	tween.parallel().tween_property(_main_menu_panel, "position:x", 0, PANEL_ANIMATION_TIME)

func _hide_main_panel() -> void:
	_main_menu_panel.process_mode = Node.PROCESS_MODE_DISABLED

	var tween: Tween = create_tween()
	tween.tween_property(_main_menu_panel, "transparacy", 0.0, PANEL_ANIMATION_TIME)
	tween.parallel().tween_property(_main_menu_panel, "position:x", -6.5, PANEL_ANIMATION_TIME)


func _show_custom_levels_panel() -> void:
	_custom_levels_panel.process_mode = Node.PROCESS_MODE_INHERIT
	

	var tween: Tween = create_tween()
	tween.tween_property(_custom_levels_panel, "transparacy", 1.0, PANEL_ANIMATION_TIME)
	tween.parallel().tween_property(_custom_levels_panel, "position:x", 0.0, PANEL_ANIMATION_TIME)

func _hide_custom_levels_panel() -> void:
	_custom_levels_panel.process_mode = Node.PROCESS_MODE_DISABLED

	var tween: Tween = create_tween()
	tween.tween_property(_custom_levels_panel, "transparacy", 0.0, PANEL_ANIMATION_TIME)
	tween.parallel().tween_property(_custom_levels_panel, "position:x", 6.5, PANEL_ANIMATION_TIME)


# Input methods ========================================


# Main menu panel ====================

func _on_main_panel_custom_levels_pressed():
	_hide_main_panel()
	_show_custom_levels_panel()


func _on_main_panel_exit_pressed():
	_exit_game()


# Custom songs panel =================

func _on_level_played( level: Level ):
	player.stop_inputs()
	player.fade_out( 0.3, _switch_to_level.bind(level) )


func _on_custom_levels_panel_back_pressed():
	_hide_custom_levels_panel()
	_show_main_panel()

