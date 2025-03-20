if (image_alpha < 1 && instance_exists(obj_battle_controller.pattern)) {
	image_alpha += 0.1;
}

array_push(particles, {
	_x: x + irandom_range(-3, 3),
	_y: y + irandom_range(-3, 3),
	size: irandom_range(0, 2)
});

if (array_length(particles) > 12) {
	array_delete(particles, 0, 1);
}

if (slowing_down) {
	move_speed -= 1 / 15;
	if (move_speed <= 0) {
		move_direction = point_direction(x, y, target_x, target_y);
		move_speed = 6;
		image_speed = 1.5;
		
		slowing_down = false;
		homing = true;
		
		if (!audio_is_playing(snd_whoosh)) {
			audio_play_sound(snd_whoosh, 1, false);
		}
	}
}

if (move_type == star_move_types.straight || homing) {
	x += lengthdir_x(move_speed, move_direction);
	y += lengthdir_y(move_speed, move_direction);
	
	if (x <= -11 || y <= -11 || x >= 651 || y >= 491) {
		// I don't like doing this, but it's probably the cleanest approach.
		if (instance_exists(obj_pattern_anser_quigley_starfall)) {
			instance_create_layer(0, -11, "bullets", obj_bullet_anser_star, {
				above: true,
				move_type: star_move_types.wave,
				move_speed: 4,
				wave_flipped: wave_flipped
			});
		}
		
		instance_destroy();
	}
} else if (move_type == star_move_types.circle) {
	move_direction -= move_speed;
	if (move_direction < 0) {
		move_direction += 360;
	}
	
	x = center_x + lengthdir_x(circle_radius, move_direction);
	y = center_y + lengthdir_y(circle_radius, move_direction);
} else if (move_type == star_move_types.wave) {
	// move_direction is ignored for waves; they always move downward
	x = 319.5 + dsin(y / 100 * 180 + (wave_flipped ? 180 : 0)) * 69.5;
	y += move_speed;
	
	if (y > 491) {
		instance_destroy();
	}
}

if (!instance_exists(obj_battle_controller.pattern)) {
	fade_out(0.1);
}