if (choose(0, 1) == 1) {
	instance_create_layer(
		164,
		irandom_range(284, 356),
		"bullets",
		obj_bullet_anser_star,
		{above: true, move_type: star_move_types.straight, move_direction: 0}
	);
} else {
	instance_create_layer(
		476,
		irandom_range(284, 356),
		"bullets",
		obj_bullet_anser_star,
		{above: true, move_type: star_move_types.straight, move_direction: 180}
	);
}

alarm[0] = 30;
audio_play_sound(snd_star, 1, false);