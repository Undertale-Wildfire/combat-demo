if (shooting) {
	if (--star_timer == 0) {
		instance_create_layer(x, (bbox_top + bbox_bottom) div 2, "bullets", obj_bullet_anser_star, {
			above: true,
			move_type: star_move_types.straight,
			move_speed: 6,
			move_direction: point_direction(x, y, obj_soul.x, obj_soul.y)
		});
		
		star_timer = 45;
		audio_play_sound(snd_star, 1, false);
	}
} else if (pulsing) {
	pulse_progress += 0.025;
	image_blend = merge_color(c_white, c_red, dsin(pulse_progress * 180));
	
	var move_progress = 1 - power(1 - pulse_progress, 3);
	x = lerp(xstart, xstart + 20, move_progress);
	y = lerp(ystart, 338, move_progress);
	
	if (pulse_progress == 1) {
		pulsing = false;
		moving = true;
	}
} else if (moving) {
	y += 6 * move_direction;
	if (bbox_top <= obj_battle_controller.box.y1 + 8) {
		y = obj_battle_controller.box.y1 + sprite_height + 8;
		move_direction = 1;
	} else if (bbox_bottom >= obj_battle_controller.box.y2 - 8) {
		y = obj_battle_controller.box.y2 - 7;
		move_direction = -1;
	}
	
	if (--star_timer == 0) {
		instance_create_layer(
			x,
			(bbox_top + bbox_bottom) div 2,
			"bullets",
			obj_bullet_anser_star,
			{above: true, move_type: star_move_types.straight, move_speed: 6, move_direction: 180}
		);
		
		star_timer = irandom_range(6, 14);
		audio_play_sound(snd_star, 1, false);
	}
}