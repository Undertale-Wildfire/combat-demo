soul_visible = !soul_visible;
if (soul_visible) {
	audio_play_sound(snd_flicker, 1, false);
} else {
	flicker_count++;
}

if (flicker_count < 3) {
	alarm[0] = 2;
} else {
	soul_visible = true;
	soul_moving = true;
	audio_play_sound(snd_battle_start, 1, false);
}