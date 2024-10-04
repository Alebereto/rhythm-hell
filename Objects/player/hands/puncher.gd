extends Hand

signal projectile_hit( projectile: Projectile )
signal projectile_touched( projectile: Projectile )


# Used for detecting hit speed
@export_range(0,1) var _hit_threshold: float = 0.1
const FORWARDS = Vector3(0,0,-1)
const MAX_POSITIONS: int = 10
var _last_position_queue: Globals.Queue


# Displaying magnitude (for testing)
@export var _display_mag: bool = false
@onready var _mag_display = $MagnitudeDisplay



# Called when the node enters the scene tree for the first time.
func _ready():
	_last_position_queue = Globals.Queue.new(MAX_POSITIONS)

	if _display_mag: _mag_display.visible = true
	else:			 _mag_display.visible = false

	set_color(color)

# Called every physics frame.
func _physics_process(_delta):
	_last_position_queue.add(global_position)

	if _display_mag:
		# update indicator of hitting speed
		if _is_hitting_speed(): $MagnitudeDisplay/FlagIndicator.get_active_material(0).albedo_color = Color.GREEN
		else:					$MagnitudeDisplay/FlagIndicator.get_active_material(0).albedo_color = Color.RED




func set_color( clr: Color ) -> void:
	$Model/Cube.get_active_material(0).albedo_color = clr
	$Model/Rod.get_active_material(0).albedo_color = clr


## Checks if puncher is currently fast enough to punch an object
func _is_hitting_speed() -> bool:
	var last_pos = _last_position_queue.peek()
	if last_pos == null: return false

	var mag = FORWARDS.dot(global_position - last_pos)

	if _display_mag: $MagnitudeDisplay/MagnitudeLabel.text = "%.3f" % mag	# update display of magnitude

	return mag >= _hit_threshold

## Called when area enters other body
func _on_body_entered( body ):
	if (body is Projectile):
		if not body.active: return
		if _is_hitting_speed():
			projectile_hit.emit( body )
			vibrate.emit()
		else:
			projectile_touched.emit( body )
