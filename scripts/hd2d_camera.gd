extends Node3D
## Orbit/pan rig for framing the HD-2D diorama.
##
## WASD — pan across the ground plane (relative to the current yaw)
## Q / E — rotate the rig
## Right mouse drag — orbit
## Mouse wheel — dolly in/out (clamped)
##
## The Camera3D child keeps its fixed downward pitch — the low-angle,
## looking-down framing is a big part of the Octopath diorama feel.

@export var move_speed: float = 7.0
@export var rotate_speed: float = 1.8
@export var orbit_sensitivity: float = 0.005
@export var zoom_step: float = 1.2
@export var min_distance: float = 5.0
@export var max_distance: float = 24.0

@onready var _camera: Camera3D = $Camera3D

var _distance: float = 12.0


func _ready() -> void:
	_distance = _camera.position.length()


func _process(delta: float) -> void:
	var dir := Vector3.ZERO
	if Input.is_key_pressed(KEY_W):
		dir.z -= 1.0
	if Input.is_key_pressed(KEY_S):
		dir.z += 1.0
	if Input.is_key_pressed(KEY_A):
		dir.x -= 1.0
	if Input.is_key_pressed(KEY_D):
		dir.x += 1.0
	if dir != Vector3.ZERO:
		dir = transform.basis * dir.normalized()
		dir.y = 0.0
		global_position += dir.normalized() * move_speed * delta

	if Input.is_key_pressed(KEY_Q):
		rotation.y += rotate_speed * delta
	if Input.is_key_pressed(KEY_E):
		rotation.y -= rotate_speed * delta


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_set_distance(_distance - zoom_step)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_set_distance(_distance + zoom_step)
	elif event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_RIGHT:
		rotation.y -= event.relative.x * orbit_sensitivity


func _set_distance(value: float) -> void:
	_distance = clampf(value, min_distance, max_distance)
	_camera.position = _camera.position.normalized() * _distance
