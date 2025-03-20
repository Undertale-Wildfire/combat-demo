moving = true;

if (!audio_is_playing(snd_whoosh)) {
	audio_play_sound(snd_whoosh, 1, false);
}