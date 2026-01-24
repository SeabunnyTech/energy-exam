extends Node

# 從一個字串中提取第一個出現的數字
# 例如: "4.離岸風力發電" -> 4
#       "答案是2" -> 2
func _extract_number_from_string(s: String) -> int:
	var num_str := ""
	for c in s:
		if c.is_valid_int():
			num_str += c
	
	if num_str.is_empty():
		printerr("無法從字串中提取答案數字: ", s)
		return -1 # 返回一個錯誤值
		
	return num_str.to_int()


# 讀取並解析指定主題的題庫 CSV 檔案
# @param topic: 題庫主題 (也是不含 .csv 副檔名的檔名)，例如 "wind"
# @return: 一個包含問題字典的陣列。讀取失敗則返回空陣列。
func load_questions(topic: String) -> Array:
	var questions: Array = []
	var file_path := "res://questions/%s.csv" % topic
	
	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)

	if file == null:
		printerr("無法打開題庫檔案: ", file_path)
		return []

	# 讀取並跳過第一行標題
	if not file.eof_reached():
		file.get_line()
	
	# 逐行讀取題目內容
	while not file.eof_reached():
		var line: String = file.get_line()
		if line.strip_edges().is_empty():
			continue
		
		var fields: Array = line.split(",", false, 9) # 最多切成9個欄位
		
		# 確保欄位數量足夠，避免出錯
		if fields.size() < 6:
			printerr("CSV 檔案格式錯誤，欄位不足: ", line)
			continue

		var question_dict := {}
		
		# 根據實際的 CSV 結構來解析
		# 0: 題號 (忽略)
		# 1: 問題題標 -> "標題"
		# 2: 問答內容 -> "內容"
		# 3: 答案 -> "答案" (純數字)
		# 4-8: 選項 -> "所有選項陣列"
		
		question_dict["標題"] = fields[1]
		question_dict["內容"] = fields[2]
		question_dict["答案"] = _extract_number_from_string(fields[3])
		
		var options: Array = []
		for i in range(4, fields.size()): # 遍歷選項欄位 (索引 4 到 8)
			var option_text: String = fields[i].strip_edges()
			if not option_text.is_empty():
				options.append(option_text)
		
		question_dict["選項"] = options
		
		questions.append(question_dict)

	file.close()
	return questions

# 範例 (僅在將此腳本附加到節點並運行場景時執行)
func _ready():
	# 示範如何使用此 Reader。
	# 如果您已將其設置為 AutoLoad (名為 QuestionReader)，
	# 請在其他腳本中用 `QuestionReader.load_questions("wind")` 的方式調用。
	var wind_questions = load_questions("wind")
	if not wind_questions.is_empty():
		print("成功讀取 'wind' 題庫，共 %d 題" % wind_questions.size())
		print("第一題內容: ", wind_questions[0])
		
	var solar_questions = load_questions("solar")
	if not solar_questions.is_empty():
		print("成功讀取 'solar' 題庫，共 %d 題" % solar_questions.size())

	var non_exist_questions = load_questions("water")
	if non_exist_questions.is_empty():
		print("嘗試讀取不存在的 'water' 題庫，返回空陣列。 (正常)")
