if (!triggered) {
	mask_index = spr_bullet_quigley_trap_trigger;
	
	if (place_meeting(x, y, obj_soul)) {
		image_speed = 1;
		triggered = true;
		audio_play_sound(snd_trap_trigger, 1, false);
	}
	
	mask_index = sprite_index;
}

if (fading) {
	fade_out(0.05);
}