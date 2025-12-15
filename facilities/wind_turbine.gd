@tool
extends Node3D

# deg per second
@export var base_speed : float = 20.0

# 避免多台風積因為轉速相同變得看起來太整齊
@export var speed_deviation : float = 2.0
@export var random_phase : bool = true

var random_speed : float = 0.0
var phase : float = 0.0

var boost_level = 0:
	set(value):
		boost_level = value
		restart_spin()


var spin_tween
func _ready() -> void:
	# --- 隨機化初始角度和速度 ---
	random_speed = randf_range(-speed_deviation, speed_deviation)
	if random_phase:
		phase = randf_range(0, 360.0)
		
	# --- 手動為旋轉的風扇設定一個固定的 AABB ---
	# 這是解決抖動的關鍵。我們將 AABB 應用在 $WindNearFan 而不是 self。
	var box_size = Vector3(30, 30, 30)
	# var box_pos = Vector3(-box_size.x / 2.0, 0, -box_size.z / 2.0)
	var box_pos = -box_size / 2.0
	#var box_pos = Vector3.ZERO
	if has_node("WindNearFan") and get_node("WindNearFan") is GeometryInstance3D:
		get_node("WindNearFan").custom_aabb = AABB(box_pos, box_size)

	restart_spin()


func restart_spin():
	# --- 使用 Tween 建立循環動畫 ---
	if spin_tween:
		spin_tween.kill()
	spin_tween = create_tween()
	spin_tween.set_loops()
	
	var current_speed = base_speed * (1. + boost_level/3.0) + random_speed
	# 避免速度為零導致除零錯誤
	if is_zero_approx(current_speed):
		return
		
	var duration = 360.0 / current_speed
	
	spin_tween.tween_property($WindNearFan, "rotation_degrees:x", 360.0 + phase, duration).from(phase)

# 不需要 _physics_process 函數
