extends Node

var scores_in_topics = reset_scores.duplicate(true)

const reset_scores = {
	'coast' : {'wind':{'answered':0, 'correct':0}},
	'east'	: {},
	'west'	: {},
}

func get_topic_score(map_name:String, topic:String):
	return scores_in_topics[map_name][topic]


func push_score(map_name:String, topic:String, is_correct:bool):
	var records = scores_in_topics[map_name][topic]
	records['answered'] += 1
	if is_correct:
		records['correct'] += 1


func load_topic_title_and_guide(map_name:String, topic:String):
	return {
		'coast' : {
			'wind':{
				'title':'離岸風電知多少!',
				'guide':'你體驗過新竹的大風嗎?\n如果你曾經被新竹的大風吹到站不穩而印象深刻\n那麼台灣海峽上空三倍速率的強風絕對會讓你更加驚嘆喔!'
			}
		}
	}[map_name][topic]
