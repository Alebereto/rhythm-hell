extends Node

const SAVE_FILE_NAME = "save.dat"
const AUDIO_FILE_NAME = "song.ogg"

const SECONDS_IN_MINUTE = 60
const MILISECONDS_IN_SECOND = 1000000.0

# var audio_path = "%s/%s" %[song_path, Globals.AUDIO_FILE_NAME]

func format_seconds(seconds: float) -> String:
	var minute = floor(seconds / float(SECONDS_IN_MINUTE))
	var second = floor(int(seconds) % SECONDS_IN_MINUTE)
	var pad = ""
	if second < 10: pad = "0"

	return "%s:%s%s" % [str(minute), pad, str(second)]
