// This is a horrible way of creating a gap in the stream, but quite honestly I can't be bothered to
// think of a better solution.
if (stars_shot < 5 || stars_shot > 6) {
	instance_create_layer(fox.x, (fox.bbox_top + fox.bbox_bottom) div 2, "bullets", obj_bullet_anser_star, {
		above: true,
		move_type: star_move_types.straight,
		move_speed: 8,
		move_direction: 90,
		wave_flipped: stars_shot > 6  // This value isn't used for this star, but will be transferred to the wave star.
	});
	
	audio_play_sound(snd_star, 1, false);
}

if (++stars_shot < 12) {
	alarm[0] = 8;
}