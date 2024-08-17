extends Label

var score_text: String = "Score: %s"


func update_score_text(new_score):
	set_text(score_text % new_score)
