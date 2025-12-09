extends Node

var scores_in_topics = {
	'coast' : {'wind':{'answered':0, 'correct':0}},
	'east'	: {},
	'west'	: {},
}


func push_score(topic:String, is_correct:bool):
	pass


func load_questions(topic:String, num:int):
	return []


func load_topic_title_and_guide(topic:String):
	pass
