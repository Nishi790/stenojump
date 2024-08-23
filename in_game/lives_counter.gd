extends Label

var life_counter_text: String = "%d Lives Remaining"

func update_lives_counter(num: int) -> void:
	set_text(life_counter_text % num)
