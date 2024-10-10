extends HFlowContainer

signal event_settings_changed(event_info: Globals.EventInfo)
signal event_settings_saved(event_info: Globals.EventInfo)

var event_info: Globals.EventInfo:
	set(info):
		event_info = info
		_update_save_button()
		_update_displays()

@onready var _name_panel: LineEdit = $EventName/LineEdit
@onready var _id_panel: SpinBox = $EventID/SpinBox
@onready var _event_color_panel: ColorPickerButton = $EventColor
@onready var _event_value_panel: SpinBox = $EventValue/SpinBox
@onready var _event_delay_panel: SpinBox = $EventDelay/SpinBox

@onready var _save_event_button: Button = $SaveEvent


func _update_displays() -> void:
	_name_panel.text = event_info.name
	_id_panel.set_value_no_signal(event_info.id)
	_event_color_panel.color = event_info.color
	_event_value_panel.set_value_no_signal(event_info.value)
	_event_delay_panel.set_value_no_signal(event_info.delay)

## Called whenever a value has changed
func _on_change() -> void:
	event_settings_changed.emit(event_info)
	_update_save_button()

func _is_savable( event: Globals.EventInfo ) -> bool:
	var event_name = event.name
	return event_name != "" and event_name != Globals.DEFAULT_ITEM_NAME

func _update_save_button() -> void:
	if _is_savable(event_info):
		_save_event_button.disabled = false
	else:
		_save_event_button.disabled = true

# Inputs ===========================================================


func _on_save_event_pressed():
	event_settings_saved.emit(event_info)


func _on_name_text_changed(new_text:String):
	event_info.name = new_text
	_on_change()

func _on_id_value_changed(value):
	event_info.id = value
	_on_change()

func _on_event_color_changed(color:Color):
	event_info.color = color
	_on_change()

func _on_event_value_changed(value:float):
	event_info.value = value
	_on_change()


func _on_delay_value_changed(value:float):
	event_info.delay = value
	_on_change()
