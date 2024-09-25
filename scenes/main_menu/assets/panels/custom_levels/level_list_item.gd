extends MarginContainer

signal item_picked( node )
signal hovered

var _level: Level = null
var _texture = null

func get_level()-> Level: return _level

# Button
@onready var _button = $Button

# For editing info
@onready var _level_image: TextureRect = $LevelInfo/LevelImage
@onready var _level_name: Label = $LevelInfo/BasicInfo/Name
@onready var _game_type: Label = $LevelInfo/BasicInfo/Type
@onready var _level_length: Label = $LevelInfo/Time/Time


func set_params(level, texture) -> void:
	_level = level
	_texture = texture

func _ready():
	_update_level_info()


func _update_level_info() -> void:
	if _level == null: return

	_level_image.texture = _texture
	_level_name.text = _level.name
	_game_type.text = Globals.MICRO_GAME_NAMES[_level.micro_game_id]
	_level_length.text = Globals.format_seconds(_level.length)

func unselect() -> void:
	_button.disabled = false

# Inputs =================

func _on_hover():
	if not _button.disabled: hovered.emit()


func _on_button_pressed():
	_button.disabled = true
	item_picked.emit( self )
