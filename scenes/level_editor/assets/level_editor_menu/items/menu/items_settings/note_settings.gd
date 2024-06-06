extends VBoxContainer

signal note_settings_changed(note: Globals.NoteInfo)
signal note_settings_saved(note: Globals.NoteInfo)


var _note_values: Globals.NoteInfo

var note_info: Globals.NoteInfo: get = _get_note_info, set = _set_note_info
func _get_note_info() -> Globals.NoteInfo: return _note_values
func _set_note_info(info: Globals.NoteInfo) -> void:
	_note_values = info
	_update_displays()


# Note Settings controllers
@onready var _name_panel: LineEdit = $Row1/NoteName/LineEdit
@onready var _note_delay_panel: SpinBox = $Row1/NoteDelay/SpinBox
@onready var _id_panel: SpinBox = $Row1/NoteID/SpinBox
@onready var _note_color_panel: ColorPickerButton = $Row2/NoteColor
@onready var _note_rotated_panel: CheckBox = $Row2/NoteRotated



## Updates values in conrol panel according to note settings.
## Used when values are changed externally
func _update_displays() -> void:
	_name_panel.text = _note_values.name
	_note_delay_panel.set_value_no_signal(_note_values.delay)
	_id_panel.set_value_no_signal(_note_values.id)
	# custom data
	_note_color_panel.color = _note_values.color
	_note_rotated_panel.set_pressed_no_signal(_note_values.rotated)


func _on_change() -> void:
	note_settings_changed.emit(note_info)



# Input signals ==============


func _on_name_edit(new_text):
	_note_values.name = new_text
	_on_change()

func _on_delay_value_changed(value):
	_note_values.delay = value
	_on_change()

func _on_id_value_changed(value):
	_note_values.id = value
	_on_change()

func _on_note_color_changed(color):
	_note_values.color = color
	_on_change()

func _on_note_rotated_toggled(toggled_on):
	_note_values.rotated = toggled_on
	_on_change()


func _on_save_note_pressed():
	note_settings_saved.emit(note_info)
