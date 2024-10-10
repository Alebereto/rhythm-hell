extends HFlowContainer

signal note_settings_changed(note_info: Globals.NoteInfo)
signal note_settings_saved(note_info: Globals.NoteInfo)


var note_info: Globals.NoteInfo:
	set(info):
		note_info = info
		_update_save_button()
		_update_displays()


# Note Settings controllers
@onready var _name_panel: LineEdit = $NoteName/LineEdit
@onready var _note_delay_panel: SpinBox = $NoteDelay/SpinBox
@onready var _id_panel: SpinBox = $NoteID/SpinBox
@onready var _note_color_panel: ColorPickerButton = $NoteColor
@onready var _note_rotated_panel: CheckBox = $NoteRotated

@onready var _save_note_button: Button = $SaveNote


## Updates values in conrol panel according to note settings.
## Used when values are changed externally
func _update_displays() -> void:
	_name_panel.text = note_info.name
	_note_delay_panel.set_value_no_signal(note_info.delay)
	_id_panel.set_value_no_signal(note_info.id)
	# custom data
	_note_color_panel.color = note_info.color
	_note_rotated_panel.set_pressed_no_signal(note_info.rotated)

## Called whenever a value has changed
func _on_change() -> void:
	note_settings_changed.emit(note_info)
	_update_save_button()

func _is_savable( note: Globals.NoteInfo ) -> bool:
	# TODO: check song length or somethingm???
	var note_name = note.name
	return note_name != "" and note_name != Globals.DEFAULT_ITEM_NAME

func _update_save_button() -> void:
	if _is_savable(note_info):
		_save_note_button.disabled = false
	else:
		_save_note_button.disabled = true


# Input signals ======================================

func _on_save_note_pressed():
	note_settings_saved.emit(note_info)


func _on_name_edit(new_text):
	note_info.name = new_text
	_on_change()

func _on_delay_value_changed(value):
	note_info.delay = value
	_on_change()

func _on_id_value_changed(value):
	note_info.id = value
	_on_change()

func _on_note_color_changed(color):
	note_info.color = color
	_on_change()

func _on_note_rotated_toggled(toggled_on):
	note_info.rotated = toggled_on
	_on_change()
