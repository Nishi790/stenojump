extends Label

var life_counter_text = "%d Lives Remaining"

func update_lives_counter(num: int):
	set_text(life_counter_text % num)
