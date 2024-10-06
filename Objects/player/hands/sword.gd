extends Hand

signal object_sliced( body: SliceObject )
signal object_shallow_sliced( body: SliceObject)

const _max_positions: int = 10
var _last_position_queue: Globals.Queue
@export_range(0,1) var _slice_threshold: float = 0.1

@onready var _blade = $Model/Blade

# Called when the node enters the scene tree for the first time.
func _ready():
	_set_color()
	_last_position_queue = Globals.Queue.new(_max_positions)

# Called every physics frame.
func _physics_process(_delta):
	_last_position_queue.add(global_position)


func _set_color():
	_blade.get_active_material(0).albedo_color = color


func _get_movement_vector() -> Vector3:
	var last_pos = _last_position_queue.peek()
	if last_pos == null: return Vector3()
	return global_position - last_pos

func _is_slicing_speed() -> bool:
	var mag = _get_movement_vector().length()
	return mag >= _slice_threshold


# Inputs ==========================================

func _on_area_3d_body_entered(body:Node3D):
	if body is SliceObject and body.is_active():
		vibrate.emit()
		if _is_slicing_speed():
			var movement: Vector3 = _get_movement_vector()
			var angle: float = Vector2(movement.x, movement.y).angle()
			body.angle = angle
			object_sliced.emit(body)
		else: object_shallow_sliced.emit(body)
