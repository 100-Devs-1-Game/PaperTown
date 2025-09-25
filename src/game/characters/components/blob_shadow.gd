class_name BlobShadow
extends MeshInstance3D

@export var raycast_distance: float = 5.0

var default_scale: Vector3
var default_offset: Vector3


func _ready() -> void:
	default_scale = scale
	default_offset = position


func _physics_process(_delta: float):
	var start := (
		(get_parent() as Node3D).global_transform.origin + (Vector3.UP * 0.1) + default_offset
	)
	var end := (
		(get_parent() as Node3D).global_transform.origin
		+ (Vector3.DOWN * raycast_distance)
		+ default_offset
	)
	var space_state := get_world_3d().direct_space_state
	var rayparams := PhysicsRayQueryParameters3D.new()
	rayparams.from = start
	rayparams.to = end
	rayparams.collision_mask = 1
	var result := space_state.intersect_ray(rayparams)

	if result:
		var hit_position: Vector3 = result.position
		var hit_normal: Vector3 = result.normal
		global_transform.origin = hit_position + hit_normal * 0.01
		transform.origin.x = default_offset.x
		transform.origin.z = default_offset.z

		look_at(hit_position + hit_normal, Vector3.FORWARD)
		rotation.x = 0
		rotation.z = 0

		# make it bigger when its further away
		var max_distance := 100.0
		var scale_per_distance := 0.05
		var distance := minf(maxf((hit_position - start).length(), 0.1), max_distance)
		var new_scale := maxf(distance / max_distance / scale_per_distance, 0.0)
		scale = Vector3(new_scale, new_scale, new_scale) + default_scale
