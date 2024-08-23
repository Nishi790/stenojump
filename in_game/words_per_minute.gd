extends Label

var word_count_message: String = "%.1f wpm"
var can_update: bool = true
var update_timer: float = 0.5


func _process(delta: float) -> void:
	update_timer -= delta
	if update_timer < 0:
		can_update = true


func update_wpm(wpm_value: float):
	if can_update:
		set_text(word_count_message % wpm_value)
		can_update = false
		update_timer = 0.5
