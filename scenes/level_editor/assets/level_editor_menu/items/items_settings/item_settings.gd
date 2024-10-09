extends PanelContainer

signal item_settings_changed(item_info: Globals.ItemInfo)
signal item_settings_saved(item_info: Globals.ItemInfo)


# Settings windows
@onready var _note_settings: HFlowContainer = $NoteSettings
@onready var _event_settings: HFlowContainer = $EventSettings
@onready var _marker_settings: HFlowContainer = $MarkerSettings


## Sets item settings and shows them
func set_item_display(item_info: Globals.ItemInfo) -> void:
	_set_settings_from_item(item_info)
	_change_to_window(item_info)


func _change_to_window(item_info: Globals.ItemInfo) -> void:
	_note_settings.visible = false
	_event_settings.visible = false
	_marker_settings.visible = false

	if item_info is Globals.NoteInfo: 		_note_settings.visible = true
	elif item_info is Globals.EventInfo: 	_event_settings.visible = true
	elif item_info is Globals.MarkerInfo: 	_marker_settings.visible = true


func _set_settings_from_item(item_info: Globals.ItemInfo) -> void:

	if	 item_info is Globals.NoteInfo:		_note_settings.note_info = item_info
	elif item_info is Globals.EventInfo:	_event_settings.event_info = item_info
	elif item_info is Globals.MarkerInfo:	_marker_settings.marker_info = item_info



# Input signals =====================


func _on_settings_changed(item: Globals.ItemInfo):
	item_settings_changed.emit(item)

func _on_settings_saved(item: Globals.ItemInfo):
	item_settings_saved.emit(item)
