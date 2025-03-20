if (image_alpha < 1 && !fading) {
	image_alpha += 0.2;
}

if (image_index == 4) {
	mask_index = spr_bullet_quigley_trap_trigger;
	audio_play_sound(snd_trap_bite, 1, false);
} else if (image_index == 5) {
	mask_index = sprite_index;
}