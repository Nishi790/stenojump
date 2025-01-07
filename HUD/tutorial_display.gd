class_name StoryRunnerTutorial

extends PanelContainer

signal tutorial_closed

@export var easy_button:Button
@export var medium_button: Button
@export var hard_button: Button
@export var difficulty_details: RichTextLabel

var beginner_speed_string: String = "[center]Socks will start at 5 strokes per minute, increasing speed by 3 words per minute until he reaches 10 strokes per minute.[/center]"
var intermediate_speed_string: String = "[center]Socks will start at 8 strokes per minute, increasing speed by 5 strokes per minute until he reaches 15 strokes per minute.[/center]"
var experienced_speed_string: String = "[center]Socks will start at 15 strokes per minute, increasing speed by 5 strokes per minute until he reaches 25 strokes per minute.[/center]"

func _ready() -> void:
	easy_button.pressed.connect(PlayerConfig.set_story_difficulty.bind(PlayerConfig.StoryDifficulty.EASY))
	medium_button.pressed.connect(PlayerConfig.set_story_difficulty.bind(PlayerConfig.StoryDifficulty.MEDIUM))
	hard_button.pressed.connect(PlayerConfig.set_story_difficulty.bind(PlayerConfig.StoryDifficulty.HARD))
	easy_button.pressed.connect(close_tutorial)
	medium_button.pressed.connect(close_tutorial)
	hard_button.pressed.connect(close_tutorial)

	easy_button.focus_entered.connect(set_difficulty_tip.bind(PlayerConfig.StoryDifficulty.EASY))
	medium_button.focus_entered.connect(set_difficulty_tip.bind(PlayerConfig.StoryDifficulty.MEDIUM))
	hard_button.focus_entered.connect(set_difficulty_tip.bind(PlayerConfig.StoryDifficulty.HARD))


func initiate_focus() -> void:
	match PlayerConfig.story_runner_base_difficulty:
		PlayerConfig.StoryDifficulty.EASY:
			easy_button.grab_focus()
		PlayerConfig.StoryDifficulty.MEDIUM:
			medium_button.grab_focus()
		PlayerConfig.StoryDifficulty.HARD:
			hard_button.grab_focus()
		_:
			medium_button.grab_focus()


func set_difficulty_tip(difficulty: PlayerConfig.StoryDifficulty) -> void:
	match difficulty:
		PlayerConfig.StoryDifficulty.EASY:
			difficulty_details.text = beginner_speed_string
		PlayerConfig.StoryDifficulty.MEDIUM:
			difficulty_details.text = intermediate_speed_string
		PlayerConfig.StoryDifficulty.HARD:
			difficulty_details.text = experienced_speed_string
		_:
			difficulty_details.text = ""


func close_tutorial() -> void:
	tutorial_closed.emit()
