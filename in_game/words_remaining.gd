extends Label

var word_count_message: String = "Words Remaining: %s"

func update_word_count(word_count: int):
	set_text(word_count_message % word_count)
