if (scrolling) {
	y -= (global.keys.confirm_held ? 8 : 2);
	if (y <= top) {
		y = top;
		scrolling = false;
		audio_sound_gain(music, 0, 2000);
		
		alarm[0] = 90;
	}
} else if (fading && !instance_exists(obj_fade)) {
	fading = false;
	should_draw = false;
	alarm[1] = 60;
}