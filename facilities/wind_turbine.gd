extends Node3D

# 基礎轉速 (度/秒)
@export var base_speed: float = 30.0

# 避免多台風機因為轉速相同變得看起來太整齊
@export var speed_deviation: float = 5.0
@export var random_phase: bool = true

var _random_speed_offset: float = 0.0
var _current_speed: float = 0.0
var _target_speed: float = 0.0

# 加速等級，每答對一題增加 1
var boost_level: int = 0:
	set(value):
		boost_level = value
		_update_target_speed()
		_update_particles()

@onready var _fan: Node3D = $WindNearFan
@onready var _particles: Array[GPUParticles3D] = [
	$WindNearFan/WindParticles1,
	$WindNearFan/WindParticles2,
	$WindNearFan/WindParticles3
]


func _ready() -> void:
	# 隨機化初始角度和速度偏移
	_random_speed_offset = randf_range(-speed_deviation, speed_deviation)
	if random_phase and _fan:
		_fan.rotation_degrees.x = randf_range(0, 360.0)

	# 設定固定的 AABB 避免視錐剔除導致的閃爍
	if _fan is GeometryInstance3D:
		var box_size = Vector3(30, 30, 30)
		_fan.custom_aabb = AABB(-box_size / 2.0, box_size)

	_update_target_speed()
	_current_speed = _target_speed
	_update_particles()


func _update_target_speed() -> void:
	# 每個 boost_level 轉速翻倍
	# 兼顧低速與高速區段的成長差距
	_target_speed = base_speed * pow(2, boost_level) + boost_level * 60.0 + _random_speed_offset


func _update_particles() -> void:
	for p in _particles:
		if p == null:
			continue

		if boost_level == 0:
			# 沒有 boost 時不顯示粒子
			p.emitting = false
		else:
			# 有 boost 時開啟粒子，數量和速度隨 boost_level 增加
			p.emitting = true
			p.amount = 5 * boost_level  # 每個發射器: boost 1: 5, boost 2: 10, boost 3: 15
			p.speed_scale = 0.5 + boost_level * 0.5  # boost 1: 1.0, boost 2: 1.5, boost 3: 2.0


func _physics_process(delta: float) -> void:
	if _fan == null:
		return

	# 平滑過渡到目標速度
	_current_speed = lerp(_current_speed, _target_speed, delta * 5.0)

	# 繞 X 軸旋轉
	_fan.rotate_x(deg_to_rad(_current_speed * delta))
