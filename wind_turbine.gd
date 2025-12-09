@tool
extends Node3D

# deg per second
@export var speed : float = 20.0

# 避免多台風積因為轉速相同變得看起來太整齊
@export var speed_deviation : float = 2.0
@export var random_phase : bool = true

var random_speed : float = 0.0
var phase : float = 0.0


func _ready() -> void:
	random_speed = randf_range(-speed_deviation, speed_deviation)
	if random_phase:
		phase = randf_range(0, 360.0)
		$WindNearFan.rotate_x(phase)

func _physics_process(delta: float) -> void:
	$WindNearFan.rotate_x(deg_to_rad(delta * (speed + random_speed)))
