if (room == rm_credits) {
	obj_credits.scrolling = true;
	obj_credits.music = audio_play_sound(mus_game_over, 1, true);
	audio_sound_pitch(obj_credits.music, 0.9);
	
	sliding_up = true;
} else if (global.combat_demo_flags.completed_tutorial) {
	show_text = true;
} else {
	instance_create_layer(320, 600, "system", obj_dummonstrous_cutscene);
	sliding_up = true;
}