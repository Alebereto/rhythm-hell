extends Area3D

signal projectile_hit( projectile: Projectile )
signal projectile_touched( projectile: Projectile )
signal vibrate

const forwards = Vector3(0,0,-1)
const max_positions: int = 10

@export_range(0,1) var _hit_threshold: float = 0.1

var _last_position_queue: Globals.Queue

var color: Color = Color.WHITE


# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(_on_body_entered)
	_last_position_queue = Globals.Queue.new(max_positions)

	set_color(color)

# Called every physics frame.
func _physics_process(_delta):
	_last_position_queue.add(global_position)

	# update indicator of hitting speed (for testing)
	if _is_hitting_speed(): $MagnitudeDisplay/FlagIndicator.get_active_material(0).albedo_color = Color.GREEN
	else:					$MagnitudeDisplay/FlagIndicator.get_active_material(0).albedo_color = Color.RED




func set_color( clr: Color ) -> void:
	$Cube.get_active_material(0).albedo_color = clr
	$Rod.get_active_material(0).albedo_color = clr


## Checks if puncher is currently fast enough to punch an object
func _is_hitting_speed() -> bool:
	var last_pos = _last_position_queue.peek()
	if last_pos == null: return false

	var mag = forwards.dot(global_position - last_pos)

	$MagnitudeDisplay/MagnitudeLabel.text = "%.3f" % mag	# update display of magnitude (for testing)

	return mag >= _hit_threshold

## Called when area enters other body
func _on_body_entered( body ):
	if (body is Projectile):
		if not body.active: return
		if _is_hitting_speed(): projectile_hit.emit( body )
		else: 					projectile_touched.emit( body )
