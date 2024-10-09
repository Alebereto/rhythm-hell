extends HFlowContainer

signal marker_settings_changed(marker_info: Globals.MarkerInfo)
signal marker_settings_saved(marker_info: Globals.MarkerInfo)

var marker_info: Globals.MarkerInfo:
	set(info):
		marker_info = info
		_update_save_button()
		_update_displays()


@onready var _name_panel: LineEdit = $MarkerName/LineEdit
@onready var _marker_color_panel: ColorPickerButton = $MarkerColor

@onready var _save_marker_button: Button = $SaveMarker


func _update_displays() -> void:
	_name_panel.text = marker_info.name
	_marker_color_panel.color = marker_info.color

## Called whenever a value has changed
func _on_change() -> void:
	marker_settings_changed.emit(marker_info)
	_update_save_button()

func _is_savable( marker: Globals.MarkerInfo ) -> bool:
	var marker_name = marker.name
	return marker_name != "" and marker_name != Globals.DEFAULT_ITEM_NAME

func _update_save_button() -> void:
	if _is_savable(marker_info):
		_save_marker_button.disabled = false
	else:
		_save_marker_button.disabled = true


# Inputs ===========================================================



func _on_save_marker_pressed():
	marker_settings_saved.emit(marker_info)


func _on_name_text_changed(new_text:String):
	marker_info.name = new_text
	_on_change()

func _on_marker_color_changed(color:Color):
	marker_info.color = color
	_on_change()
