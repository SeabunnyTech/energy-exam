extends AudioStreamPlayer

## Narration - 語音口白
## 客戶只提供英文語音，中文模式不播放；播放期間背景音樂會調小
## 畫面透過 BaseScreen.start_narration() 使用，播完才開放點選

## 播完或被中止時發出（AudioStreamPlayer.finished 在 stop() 時不會發出）
signal ended

const EN_CLIPS := {
	"intro": preload("res://narration/en/intro.mp3"),
	"wind": preload("res://narration/en/wind.mp3"),
	# 地面型與屋頂型太陽能共用同一段
	"solar_ground": preload("res://narration/en/solar.mp3"),
	"solar_roof": preload("res://narration/en/solar.mp3"),
	"hydro": preload("res://narration/en/hydro.mp3"),
	"geothermal": preload("res://narration/en/geothermal.mp3"),
	"energy_storage": preload("res://narration/en/energy_storage.mp3"),
}


func _ready() -> void:
	finished.connect(_on_ended)


func speak(key: String) -> void:
	stop_speaking()
	if not Lang.is_en():
		return
	if not EN_CLIPS.has(key):
		push_warning("[Narration] 找不到語音：%s" % key)
		return
	stream = EN_CLIPS[key]
	GlobalAudioPlayer.duck(true)
	play()


func stop_speaking() -> void:
	if playing:
		stop()
		_on_ended()


func _on_ended() -> void:
	GlobalAudioPlayer.duck(false)
	ended.emit()
