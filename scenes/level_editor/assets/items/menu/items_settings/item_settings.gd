extends PanelContainer

signal item_settings_changed(item_info: Globals.ItemInfo)
signal item_settings_saved(item_info: Globals.ItemInfo)


# Settings windows
@onready var _note_settings = $NoteSettings
@onready var _event_settings = $EventSettings
@onready var _marker_settings = $MarkerSettings



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _change_to_window(item_type: Globals.ITEM_TYPE) -> void:
	_note_settings.visible = false
	_event_settings.visible = false
	_marker_settings.visible = false

	match item_type:
		Globals.ITEM_TYPE.NOTE: _note_settings.visible = true
		Globals.ITEM_TYPE.EVENT: _event_settings.visible = true
		Globals.ITEM_TYPE.MARKER: _marker_settings.visible = true


func _set_item_settings(item: Globals.ItemInfo) -> void:
	match item.type:
		Globals.ITEM_TYPE.NOTE: _note_settings.note_info = item
		Globals.ITEM_TYPE.EVENT: _event_settings.event_info = item
		Globals.ITEM_TYPE.MARKER: _marker_settings.marker_info = item


func set_item_display(item: Globals.ItemInfo) -> void:
	_set_item_settings(item)
	_change_to_window(item.type)


# Recieved signals =====================


func _on_settings_changed(item: Globals.ItemInfo):
	item_settings_changed.emit(item)

func _on_settings_saved(item: Globals.ItemInfo):
	item_settings_saved.emit(item)
