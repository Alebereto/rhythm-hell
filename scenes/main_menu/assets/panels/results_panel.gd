extends Control

signal restart_pressed( level: Level )
signal continue_pressed

signal hovered

var _level: Level


func load( load_data: Globals.MainMenuLoadData ):
	var results = load_data.get_results_dict()
	_level = results["level"]
	# TODO: update score info
	var hit_notes = results["hit_notes"]
	var perfect_notes = results["perfect_notes"]
	print(hit_notes)
	print(perfect_notes)
	_set_clear_status(not results["aborted"])
	_update_level_info()


func _update_level_info():
	$Layout/LevelInfo/LevelImage.texture = _level.texture
	$Layout/LevelInfo/BasicInfo/Name.text = _level.name
	$Layout/LevelInfo/BasicInfo/Type.text = Globals.MICRO_GAME_NAMES[_level.micro_game_id]
	$Layout/LevelInfo/TimeInfo/Time.text = Globals.format_seconds(_level.length)

func _set_clear_status(cleared: bool):
	var clear = "Level Cleared" if cleared else "Aborted"
	$Layout/ClearStatus.text = clear

func _set_score_info(): pass

# Inputs =================================================

func _on_restart_button_pressed():
	restart_pressed.emit(_level)


func _on_continue_button_pressed():
	continue_pressed.emit()


func _on_hover():
	hovered.emit()
