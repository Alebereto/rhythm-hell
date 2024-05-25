extends HBoxContainer

@onready var file_tab: MenuButton = $File
@onready var view_tab: MenuButton = $View

var file_popup: PopupMenu: get = _get_file_popup

func _get_file_popup() -> PopupMenu: return file_tab.get_popup()
