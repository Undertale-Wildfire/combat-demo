if (enemy.state == enemy_states.spared) {
	image_alpha = 0.5;
} else {
	image_alpha = 1;
}

if (global.encounter.transformed) {
	if (!instance_exists(obj_damage_bar)) {
		if (enemy.current_health > 0) {
			for (var i = 0; i < 3; i++) {
				if (twitching[i].dir != 0) {
					twitching[i].progress += 0.25;
					if (twitching[i].progress == 1) {
						twitching[i].dir = 0;
					}
				}
			}
		} else if (y < 230) {
			y_speed += 0.5;
			y += y_speed;
			if (y > 230) {
				y = 230;
			}
		}
		
		center_y = y - sprite_height div 2;
	}
} else if (image_index == 0 && enemy.current_health < enemy.max_health) {
	image_index = 1;
}