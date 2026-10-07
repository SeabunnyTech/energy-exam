extends BaseScreen

var map_name
var topic

# 照相圖框網頁的 QR Code：英文版指向 ?lang=en
const QR_EN := preload("res://screens/ending/photo-frame-qrcode-en.png")
var _qr_zh: Texture2D

var celebration_frames: Array[Texture2D] = []
var celebration_durations := [0.2, 0.2, 0.1]  # seconds per frame
var current_frame := 0
var frame_timer := 0.0


# 英文標題較長，改為兩行並放寬範圍（中文維持原本版面）；順序為 [左, 上, 右, 下]
const TITLE_ANCHORS_ZH := [0.6070312, 0.15, 0.89140624, 0.21]
const TITLE_ANCHORS_EN := [0.5574, 0.10, 0.941, 0.235]
const GUIDE_ANCHORS_ZH := [0.55742186, 0.2375, 0.9410156, 0.35364583]
const GUIDE_ANCHORS_EN := [0.5574, 0.25, 0.941, 0.36]


func on_pre_enter(_param):
	$GuideLabel.text = Lang.t("congrats_title")
	$GuideLabel2.text = Lang.t("congrats_guide")
	$GuideLabel.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if Lang.is_en() else TextServer.AUTOWRAP_OFF
	Lang.set_anchors($GuideLabel, TITLE_ANCHORS_ZH, TITLE_ANCHORS_EN)
	Lang.set_anchors($GuideLabel2, GUIDE_ANCHORS_ZH, GUIDE_ANCHORS_EN)
	Lang.fit_font($GuideLabel, 60, 36)
	Lang.fit_font($GuideLabel2, 45, 24)
	$QRCodeRect.texture = QR_EN if Lang.is_en() else _qr_zh


func on_enter(_param):
	pass
	#$sfx.play()


func _ready() -> void:
	ui_to_fade = [$GuideLabel, $GuideLabel2, %LeaveButton, $TextureRect, $QRCodeRect]
	_qr_zh = $QRCodeRect.texture

	for i in 3:
		celebration_frames.append(load("res://screens/ending/celebration/frame_%d.png" % i))

	%LeaveButton.pressed.connect(_on_leave_pressed)
	reset()


func _process(delta):
	if celebration_frames.is_empty():
		return
	frame_timer += delta
	if frame_timer >= celebration_durations[current_frame]:
		frame_timer = 0.0
		current_frame = (current_frame + 1) % celebration_frames.size()
		$TextureRect.texture = celebration_frames[current_frame]


func _on_leave_pressed():
	leave_for_screen('welcome')
	GlobalAudioPlayer.fade_out(1.0)
