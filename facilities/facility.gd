class_name Facility
extends Area3D

# 當此設施被玩家點擊時發出，通知其父層 (Map)
signal clicked(facility: Facility)

@export var facility_id: String = "default_facility"

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var camera_target: Node3D = $CameraTarget

func _ready():
	self.input_event.connect(_on_input_event)

# --- 公開 API ---

func select():
	print("設施 %s 被選中，播放 'selected_animation' 動畫。" % facility_id)
	if animation_player and animation_player.has_animation("selected_animation"):
		animation_player.play("selected_animation")

func update_progress(progress: float):
	print("設施 %s 進度更新至 %.2f" % [facility_id, progress])
	# 這裡可以根據 progress 控制動畫
	# 例如: animation_player.seek(animation_player.get_animation("progress_full").length * progress)

func complete(correct_rate: float):
	print("設施 %s 問答完成，答對率: %.2f" % [facility_id, correct_rate])
	if correct_rate >= 0.8:
		if animation_player and animation_player.has_animation("complete_good"):
			animation_player.play("complete_good")
	else:
		if animation_player and animation_player.has_animation("complete_bad"):
			animation_player.play("complete_bad")

func get_camera_target() -> Node3D:
	return camera_target

# --- 私有邏輯 ---

func _on_input_event(camera: Camera3D, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		clicked.emit(self)
