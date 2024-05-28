extends VBoxContainer


signal changed_snap_beats(v: float)


@onready var _label: Label = $Label
@onready var _slider: HSlider = $HBoxContainer/HSlider



var default_slider_value: int = 3

const LABEL_TEXT: String = "Snap Beats: "


# Called when the node enters the scene tree for the first time.
func _ready():
	_slider.value = default_slider_value
	_on_slider_value_change(default_slider_value)


func _update_label_text(changed_value: float) -> void:
	_label.text = LABEL_TEXT + str(changed_value)


## Convert scroller range to desired value
func _slider_to_real(v: float) -> float:
	return 2**(v-3)


# Input functions =================

## Called when pressing reset button
func _on_reset_button_pressed() -> void:
	if _slider.value == default_slider_value: return # nothing changed

	_slider.value = default_slider_value

## Called when value of _slider changes
func _on_slider_value_change(changed_value: float) -> void:
	var snap = _slider_to_real(changed_value)

	_update_label_text(snap)
	changed_snap_beats.emit(snap)
