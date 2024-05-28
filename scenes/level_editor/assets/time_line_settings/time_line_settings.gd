extends PanelContainer

signal change_snap_beats(value: float)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_changed_snap_beats(v: float):
	change_snap_beats.emit(v)

func _on_changed_tool(t: Globals.TOOL) -> void:
	pass
