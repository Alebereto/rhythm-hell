extends Control


signal level_played( level: Level )
signal back_pressed

signal hovered

# Level list
@onready var _level_items_root = $Main/Levels/ScrollContainer/LevelsList
const LEVEL_ITEM_SCENE = preload("res://scenes/main_menu/assets/panels/custom_levels/level_list_item.tscn")


# For selected item
@onready var _selected_panel = $Main/Levels/SelectedLevel
var _selected_level_item = null


# Called when the node enters the scene tree for the first time.
func _ready():
	_load_levels()



func _add_level_item_box( level: Level, image_path = null):
	# init level item
	var level_item = LEVEL_ITEM_SCENE.instantiate()
	level_item.set_params( level, image_path )
	_level_items_root.add_child(level_item)
	# connect level item signals
	level_item.hovered.connect(_on_hover)
	level_item.item_picked.connect(_on_level_item_pressed)
	


func _load_levels() -> void:
	var levels_data = Globals.get_levels_data()
	for data in levels_data:
		_add_level_item_box(data[0], data[1])


func _update_selected_level_panel_info( level_item ) -> void:
	# TODO: update image
	var l = level_item.get_level()
	$Main/Levels/SelectedLevel/VBoxContainer/LevelInfo/BasicInfo/Name.text = l.name
	$Main/Levels/SelectedLevel/VBoxContainer/LevelInfo/BasicInfo/Type.text = Globals.MICRO_GAME_NAMES[l.micro_game_id]
	$Main/Levels/SelectedLevel/VBoxContainer/LevelInfo/Time/Time.text = Globals.format_seconds(l.length)

func _on_leave_panel() -> void:
	_selected_panel.visible = false

	if _selected_level_item != null: _selected_level_item.unselect()
	_selected_level_item = null


# Input buttons ====================

func _on_back_pressed():
	_on_leave_panel()
	back_pressed.emit()


func _on_hover():
	hovered.emit()


func _on_level_item_pressed( level_item ):
	# unselect current selected level
	if _selected_level_item != null:
		_selected_level_item.unselect()

	_selected_level_item = level_item
	_update_selected_level_panel_info( _selected_level_item )
	_selected_panel.visible = true


func _on_play_button_pressed():
	if _selected_level_item != null:
		level_played.emit( _selected_level_item.get_level() )
