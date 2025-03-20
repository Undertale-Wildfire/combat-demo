if (moving) {
	x += speed_x;
	y += speed_y;
}

if (bounce) {
	var box = obj_battle_controller.box;
	if (!inside_box && x >= box.x1 + 13 && y >= box.y1 + 13 && x <= box.x2 - 12 && y <= box.y2 - 12) {
		inside_box = true;
	}
	
	if (inside_box) {
		var speed_x_old = speed_x;
		var speed_y_old = speed_y;
		
		if (x < box.x1 + 13) {
			x = box.x1 + 13;
			speed_x = -speed_x;
		} else if (y < box.y1 + 13) {
			y = box.y1 + 13;
			speed_y = -speed_y;
		} else if (x > box.x2 - 12) {
			x = box.x2 - 12;
			speed_x = -speed_x;
		} else if (y > box.y2 - 12) {
			y = box.y2 - 12;
			speed_y = -speed_y;
		}
		
		if (speed_x != speed_x_old || speed_y != speed_y_old) {
			audio_play_sound(snd_bullet_bounce, 1, false);
		}
	}
}

if (moving && (abs(320 - x) >= 94 || abs(320 - y) >= 94)) {
	speed_x = 0;
	speed_y = 0;
	disappearing = true;
}

if (disappearing) {
	image_alpha -= 0.1;
	if (image_alpha == 0) {
		instance_destroy();
	}
} else if (image_alpha < 1) {
	image_alpha += 0.1;
	if (image_alpha == 1) {
		alarm[0] = 10;
	}
}