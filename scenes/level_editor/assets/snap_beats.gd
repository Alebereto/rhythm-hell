extends VBoxContainer


@onready var label: Label = $Label
@onready var slider: HSlider = $HBoxContainer/HSlider
@onready var reset_button: Button = $HBoxContainer/Button

signal changed_snap_beats(v: float)

var default_slider_value: int = 3

var value: float: get = _get_value
func _get_value() -> float: return _slider_to_real(slider.value)

const LABEL_TEXT: String = "Snap Beats: "


# Called when the node enters the scene tree for the first time.
func _ready():
	slider.value = default_slider_value

	slider.value_changed.connect(_on_slider_value_change)
	reset_button.pressed.connect(_on_reset_button_pressed)

	_update_label_text(value)


func _update_label_text(changed_value: float) -> void:
	label.text = LABEL_TEXT + str(changed_value)


func _on_reset_button_pressed() -> void:
	if slider.value == default_slider_value: return # nothing changed

	slider.value = default_slider_value
	_on_slider_value_change(default_slider_value)

func _slider_to_real(v: float) -> float:
	return 2**(v-3)

func _on_slider_value_change(changed_value: float) -> void:
	var snap = _slider_to_real(changed_value)

	_update_label_text(snap)
	changed_snap_beats.emit(snap)
