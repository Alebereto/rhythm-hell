@tool
class_name VRUI extends Area3D

## Emit when hovering over certain buttons
signal hovered

var _last_event_pos = null


@onready var _collision: CollisionShape3D = $CollisionShape3D
@onready var _sprite: Sprite3D = $Sprite3D

@export var _ui_viewport: SubViewport = null:
	set(viewport):
		_ui_viewport = viewport
		if Engine.is_editor_hint():
			if _sprite == null: return
			_update_viewport()


@export_range(0,1) var transparacy: float:
	set(value):
		if not _ui_viewport: return
		var node = _ui_viewport.get_child(0)
		if node is Control:
			node.modulate.a = clamp(value, 0, 1)
	get:
		if not _ui_viewport: return 0
		var node = _ui_viewport.get_child(0)
		if node is Control: return node.modulate.a
		else: return 1


# Called when the node enters the scene tree for the first time.
func _ready():
	_update_viewport()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _update_viewport():
	_sprite.texture = _ui_viewport.get_texture()

	var size = Vector2(_ui_viewport.size) * _sprite.pixel_size
	_collision.shape.size.x = size.x
	_collision.shape.size.y = size.y


## Converts global position of the ray intersection to point on viewport in pixels
func _intersect_to_pixels(ray_pos: Vector3) -> Vector2:
	var local_pos: Vector3 = to_local(ray_pos)
	var plane_pos: Vector2 = Vector2(local_pos.x, -local_pos.y) / _sprite.pixel_size
	plane_pos.x += float(_ui_viewport.size.x) / 2
	plane_pos.y += float(_ui_viewport.size.y) / 2

	return plane_pos


## Create a click/release event in given coord
func _create_mouse_click_event(viewport_point: Vector2, click: bool) -> void:
	var ev = InputEventMouseButton.new()

	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = click

	var button_mask = MOUSE_BUTTON_MASK_LEFT if click else 0
	ev.button_mask = button_mask
	ev.position = viewport_point
	ev.global_position = viewport_point

	_ui_viewport.push_input(ev)

## Create a mouse movement event in given position
func _create_mouse_motion_event(viewport_point: Vector2, clicking: bool) -> void:
	var ev = InputEventMouseMotion.new()

	var relative_pos: Vector2 = Vector2(0,0)
	if not _last_event_pos == null:
		relative_pos = viewport_point - _last_event_pos
	_last_event_pos = viewport_point
	ev.relative = relative_pos

	var button_mask = MOUSE_BUTTON_MASK_LEFT if clicking else 0
	ev.button_mask = button_mask
	ev.position = viewport_point
	ev.global_position = viewport_point

	_ui_viewport.push_input(ev)


## Called by wand when it stops pointing at ui
func on_ray_leave() -> void:
	var p = Vector2(-1,-1)
	_create_mouse_click_event(p, false)
	_create_mouse_motion_event(p, false)
	_last_event_pos = null


## Called by wand when pointing at ui
func on_ray_movement(cast_point: Vector3, clicking: bool) -> void:
	var viewport_point: Vector2 = _intersect_to_pixels(cast_point)
	_create_mouse_motion_event(viewport_point, clicking)

## Called by wand when clicking on ui
func on_ray_button(cast_point: Vector3, click: bool) -> void:
	var viewport_point: Vector2 = _intersect_to_pixels(cast_point)
	_create_mouse_click_event(viewport_point, click)


## Called when pointer hovers over buttons
func _on_hovered():
	hovered.emit()
