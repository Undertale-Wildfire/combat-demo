if (falling) {
	y += y_speed++;
	if (y >= obj_battle_controller.box.y2 - 4) {
		y = obj_battle_controller.box.y2 - 4;
		if (bounces < 3) {
			y_speed = -6 + bounces++ * 2;
			audio_play_sound(snd_bullet_bounce, 1, false);
		} else {
			falling = false;
			lighting_up = true;
			audio_play_sound(snd_trap_trigger, 1, false);
		}
	}
} else if (lighting_up) {
	lighting_up_progress += 0.1;
	image_blend = merge_color(c_gray, c_white, lighting_up_progress);
	
	if (lighting_up_progress == 1) {
		lighting_up = false;
		image_speed = 1;
		audio_play_sound(snd_trap_bite, 1, false);
	}
}