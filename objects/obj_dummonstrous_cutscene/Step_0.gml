if (!reached_center) {
	y -= 2;
	if (y == 230) {
		alarm[0] = 30;
		reached_center = true;
		audio_sound_gain(drums, 0, 250);
	}
}