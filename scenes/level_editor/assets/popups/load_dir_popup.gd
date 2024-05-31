extends FileDialog

signal dir_select_resolved(dir)


func _ready():
	dir_selected.connect(_on_load_dir_select)
	canceled.connect(_on_load_dir_cancelled)

func _on_load_dir_select(path: String) -> void:
	dir_select_resolved.emit(path)

func _on_load_dir_cancelled() -> void:
	dir_select_resolved.emit(null)
