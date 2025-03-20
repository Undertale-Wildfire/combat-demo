if (image_alpha < 1) {
	image_alpha += 0.1;
	if (image_alpha == 1) {
		alarm[0] = 10;
	}
}

if (moving) {
	x += speed_x;
	y += speed_y;
	
	if (inside_box) {	
		if (decelerating) {
			speed_x -= 0.2 * sign(speed_x);
			speed_y -= 0.2 * sign(speed_y);
			
			if (speed_x == 0) {  // Both will be 0 at the same time
				moving = false;
				activating = true;
				audio_play_sound(snd_caltrop_activate, 1, false);
			};
		}
		
		var speed_x_old = speed_x;
		var speed_y_old = speed_y;
		
		if (x < box.x1 + 9) {
			x = box.x1 + 9;
			speed_x = -speed_x;
		} else if (y < box.y1 + 9) {
			y = box.y1 + 9;
			speed_y = -speed_y;
		} else if (x > box.x2 - 8) {
			x = box.x2 - 8;
			speed_x = -speed_x;
		} else if (y > box.y2 - 8) {
			y = box.y2 - 8;
			speed_y = -speed_y;
		}
		
		if (speed_x != speed_x_old || speed_y != speed_y_old) {
			audio_play_sound(snd_bullet_bounce, 1, false);
		}
	} else if (x >= box.x1 + 9 && y >= box.y1 + 9 && x <= box.x2 - 8 && y <= box.y2 - 8) {
		inside_box = true;
	}
} else if (activating) {
	image_index += 1 / 3;
	image_blend = merge_color(c_gray, c_white, image_index / image_number);
	
	if (image_index >= image_number - 1) {
		image_index = image_number - 1;
		image_blend = c_white;
		
		dangerous = true;
		activating = false;
	} else if (image_index == 2) {
		// Move the caltrop out of the border
		// Making the move on this frame looks the least strange, as the caltrop is already drastically
		// changing in size, so the position jump isn't quite as noticeable (it's not perfect, but what can
		// you do?).
		if (x < box.x1 + 19) {
			x = box.x1 + 19;
		} else if (x > box.x2 - 18) {
			x = box.x2 - 18;
		}
		
		if (y < box.y1 + 19) {
			y = box.y1 + 19;
		} else if (y > box.y2 - 18) {
			y = box.y2 - 18;
		}
	}
}