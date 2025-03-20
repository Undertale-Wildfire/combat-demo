if (pulsing) {
	pulse_progress += 0.05;
	image_blend = merge_color(c_white, c_red, dsin(pulse_progress * 180));
	
	if (pulse_progress == 1) {
		pulsing = false;
		barking = true;
	}
} else if (barking) {
	if (bark_timer == 10 || bark_timer == 18) {
		sprite_index = spr_bullet_quigley_dog_bark;
		audio_play_sound(snd_dog_bark, 1, false);
	} else if (bark_timer == 14 || bark_timer == 22) {
		sprite_index = spr_bullet_quigley_dog;
	} else if (bark_timer == 26) {
		sprite_index = spr_bullet_quigley_dog_walk;
	} else if (bark_timer == 35) {
		barking = false;
		walking = true;
	}
	
	bark_timer++;
} else if (walking && (!instance_exists(obj_quigley_reticle) || obj_quigley_reticle.locked_on)) {
	x += 2;
	
	if (bbox_right >= obj_battle_controller.box.x1 - 3) {
		walking = false;
		jumping = true;
	}
} else if (jumping) {
	sprite_index = spr_bullet_quigley_dog_jump;
	
	speed_x += sign(obj_soul.x - x) * 0.1;
	x += speed_x;
	y += speed_y;
	speed_y += 0.22;
	
	if (bbox_top > 479) {
		jumping = false;
		
		call_later(30, time_source_units_frames, function() {
			instance_destroy(obj_bullet);
			instance_destroy(obj_battle_controller.pattern);
		});
	}
}