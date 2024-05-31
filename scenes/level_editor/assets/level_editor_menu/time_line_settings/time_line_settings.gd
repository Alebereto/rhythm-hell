extends PanelContainer

signal snap_beats_changed(value: float)
signal tool_changed(t: Globals.TOOL)

@onready var _snap_beats = $HBoxContainer/SnapBeats
@onready var _tools = $HBoxContainer/Tools


func load_song(_song: Song) -> void:
	change_tool_to(Globals.TOOL.SELECT)
	_snap_beats.on_level_load()


func change_tool_to(t: Globals.TOOL) -> void:
	_tools.select(t)	# set visual for selection (does not emit signal)
	tool_changed.emit(t)

# Input signals =====================

func _on_changed_snap_beats(v: float):
	snap_beats_changed.emit(v)


func _on_tools_item_selected(index) -> void:
	change_tool_to(index)
