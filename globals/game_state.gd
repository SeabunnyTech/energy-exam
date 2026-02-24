extends Node

## GameState - 遊戲狀態管理
## 現在使用 ContentLoader 讀取政策和主題資料

var scores_in_topics = reset_scores.duplicate(true)

const reset_scores = {
	'coast' : {
		'wind':{'answered':0, 'correct':0},
		'solar_ground':{'answered':0, 'correct':0},
		'solar_roof':{'answered':0, 'correct':0},
		'energy_storage':{'answered':0, 'correct':0},
	},
	'east' : {
		'geothermal':{'answered':0, 'correct':0},
		'hydro':{'answered':0, 'correct':0},
		'solar_roof':{'answered':0, 'correct':0},
		'energy_storage':{'answered':0, 'correct':0},
	},
	'west' : {
		'solar_ground':{'answered':0, 'correct':0},
		'hydro':{'answered':0, 'correct':0},
		'energy_storage':{'answered':0, 'correct':0},
	},
}

func reset_all_scores():
	scores_in_topics = reset_scores.duplicate(true)


func get_topic_score(map_name:String, topic:String):
	if not scores_in_topics.has(map_name) or not scores_in_topics[map_name].has(topic):
		push_warning("[GameState] get_topic_score: 找不到 map='%s', topic='%s'" % [map_name, topic])
		return {'answered': 0, 'correct': 0}
	return scores_in_topics[map_name][topic]


func push_score(map_name:String, topic:String, is_correct:bool):
	if not scores_in_topics.has(map_name) or not scores_in_topics[map_name].has(topic):
		push_warning("[GameState] push_score: 找不到 map='%s', topic='%s'，請在 reset_scores 中添加" % [map_name, topic])
		return
	var records = scores_in_topics[map_name][topic]
	records['answered'] += 1
	if is_correct:
		records['correct'] += 1

func load_policy(map_name: String, topic: String):
	# 使用 ContentLoader 讀取政策文字
	return ContentLoader.get_policy(map_name, topic)


func load_topic_title_and_guide(map_name: String, topic: String):
	# 使用 ContentLoader 讀取標題和引導文字
	return ContentLoader.get_topic_title_and_guide(map_name, topic)
