extends Node

## QuestionReader - 題庫讀取器
## 現在使用 ContentLoader 讀取題目，保持 API 相容性


# 讀取指定主題的題庫
# @param topic: 題庫主題，例如 "wind"
# @return: 一個包含問題字典的陣列。讀取失敗則返回空陣列。
func load_questions(topic: String) -> Array:
	# 使用 ContentLoader 取得題目（已轉換為相容格式）
	return ContentLoader.get_questions_for_quiz(topic)


# 範例 (僅在將此腳本附加到節點並運行場景時執行)
func _ready():
	# 等待 ContentLoader 初始化
	await get_tree().process_frame

	# 示範如何使用此 Reader。
	var wind_questions = load_questions("wind")
	if not wind_questions.is_empty():
		print("[QuestionReader] 成功讀取 'wind' 題庫，共 %d 題" % wind_questions.size())

	var solar_questions = load_questions("solar")
	if not solar_questions.is_empty():
		print("[QuestionReader] 成功讀取 'solar' 題庫，共 %d 題" % solar_questions.size())
