extends Label

var word_count_message: String = "%.1f wpm"

func update_wpm(wpm_value: float):
	set_text(word_count_message % wpm_value)
