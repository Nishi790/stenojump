extends AudioStreamPlayer2D



func play_conditional(target_stream: AudioStream, playback_position: float = 0.0) -> void:
	if not playing:
		stream = target_stream
		play(playback_position)
	elif stream != target_stream:
		stream = target_stream
		play(playback_position)
	else:
		return
