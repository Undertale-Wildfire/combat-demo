if (time < 15) {
	var progress = 1 - power(2, time / 15 * -10);
	y = ystart - progress * 20;
	image_alpha = progress;
	
	if (++time == 15) {
		y = ystart - 20;
		image_alpha = 1;
		audio_play_sound(snd_whoosh, 1, false);
	}
} else if (!reached_bottom) {
	y += 15;
	if (y > obj_battle_controller.box.y2 - 4) {
		y = obj_battle_controller.box.y2 - 4;
		reached_bottom = true;
		alarm[0] = 10;
		audio_play_sound(snd_rapier_stab, 1, false);
	}
} else if (time++ < 30) {
	var time_real = (time - 15) / 15;
	image_angle = dsin(time_real * 2160) * exp(-time_real) * 2;
}

if (fading) {
	fade_out(0.05);
}