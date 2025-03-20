if (!instance_exists(obj_bullet_dummonstrous)) {
	if (remaining_lines) {
		var side = choose(directions.right, directions.up, directions.left, directions.down);
		var missing = irandom_range(0, 5);
		
		if (side == directions.left || side == directions.right) {
			var bullet_x;
			var bullet_direction;
			
			if (side == directions.left) {
				bullet_x = 226;
				bullet_direction = 0;
			} else {
				bullet_x = 413;
				bullet_direction = 180;
			}
			
			for (var i = 0; i < 6; i++) {
				if (i != missing) {
					instance_create_layer(bullet_x, 265 + i * 22, "bullets", obj_bullet_dummonstrous, {
						above: true,
						dir: bullet_direction
					});
				}
			}
		} else {
			var bullet_y;
			var bullet_direction;
			
			if (side == directions.up) {
				bullet_y = 226;
				bullet_direction = 270;
			} else {
				bullet_y = 413;
				bullet_direction = 90;
			}
			
			for (var i = 0; i < 6; i++) {
				if (i != missing) {
					instance_create_layer(265 + i * 22, bullet_y, "bullets", obj_bullet_dummonstrous, {
						above: true,
						dir: bullet_direction
					});
				}
			}
		}
		
		remaining_lines--;
	} else {
		instance_destroy();
	}
}