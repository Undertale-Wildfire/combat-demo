if (global.encounter.transformed && enemy.current_health > 0) {
	// Cancel out the timer increase if currently taking damage; Dummonstrous should freeze in place here
	if (instance_exists(obj_damage_bar)) {
		bob_timer--;
	}
	
	var draw_y = y + dsin(bob_timer++ * 6 % 360) * -10;
	
	if (twitching[0].dir == 0) {
		draw_sprite_ext(spr_enemy_dummonstrous_stand, 0, x, draw_y - 9, 1, 1, 0, c_white, image_alpha);
	} else {
		draw_sprite_ext(spr_enemy_dummonstrous_stand, 0, x, draw_y - 9, 1, 1, dsin(twitching[0].progress * 180) * 3 * twitching[0].dir, c_white, image_alpha);
	}
	
	if (twitching[1].dir == 0) {
		draw_sprite_ext(
			spr_enemy_dummonstrous_body,
			enemy.current_health < global.encounter.health_after_transforming,
			x,
			draw_y - 44,
			1,
			1,
			0,
			c_white,
			image_alpha
		);
	} else {
		draw_sprite_ext(
			spr_enemy_dummonstrous_body,
			enemy.current_health < global.encounter.health_after_transforming,
			x,
			draw_y - 44,
			1,
			1,
			dsin(twitching[1].progress * 180) * 3 * twitching[1].dir,
			c_white,
			image_alpha
		);
	}
	
	if (twitching[2].dir == 0) {
		draw_sprite_ext(spr_enemy_dummonstrous_head, 0, x - 14, draw_y - 83, 1, 1, 0, c_white, image_alpha);
	} else {
		draw_sprite_ext(spr_enemy_dummonstrous_head, 0, x - 14, draw_y - 83, 1, 1, dsin(twitching[2].progress * 180) * 3 * twitching[2].dir, c_white, image_alpha);
	}
} else {
	draw_self();
}