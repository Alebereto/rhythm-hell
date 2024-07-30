extends Area3D

signal projectile_hit( projectile: Projectile )
signal projectile_touched( projectile: Projectile )

var color: Color = Color.WHITE


# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(_on_body_entered)

	set_color(color)

func set_color( clr: Color ) -> void:
	var mat = $Cube.get_active_material(0).duplicate()
	mat.albedo_color = color
	$Cube.set_surface_override_material(0, mat)
	$Rod.set_surface_override_material(0, mat)


# Called every physics frame.
func _physics_process(_delta):
	pass


## Checks if puncher is currently fast enough to punch an object
func _is_hitting_speed() -> bool:
	return true

## Called when area enters other body
func _on_body_entered( body ):
	if (body is Projectile):
		if not body.active: return
		if _is_hitting_speed(): projectile_hit.emit( body )
		else: 					projectile_touched.emit( body )
