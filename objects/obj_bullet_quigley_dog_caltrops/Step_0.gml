if (pulsing) {
	pulse_progress += 0.05;
	image_blend = merge_color(c_white, c_red, dsin(pulse_progress * 180));
	
	if (pulse_progress == 1) {
		pulsing = false;
		moving = true;
	}
} else if (moving) {
	y += 4 * move_direction;
	if (bbox_top <= obj_battle_controller.box.y1) {
		y = obj_battle_controller.box.y1 + sprite_height;
		move_direction = 1;
	} else if (bbox_bottom >= obj_battle_controller.box.y2) {
		y = obj_battle_controller.box.y2 + 1;
		
		if (caltrops_shot < caltrop_count) {
			move_direction = -1;
		} else {
			moving = false;
			
			// This works for all the patterns this bullet is used in.
			// A bit hacky, but it works.
			obj_battle_controller.pattern.alarm[1] = 120;
		}
	}
	
	if (--caltrop_timer == 0) {
		instance_create_layer(x + 31 * image_xscale, (bbox_top + bbox_bottom) div 2, "bullets", obj_bullet_quigley_caltrop, {above: true});
		
		if (++caltrops_shot < caltrop_count) {
			caltrop_timer = irandom_range(caltrop_count == 9 ? 10 : 20, caltrop_count == 9 ? 20 : 40);
		}
	}
}