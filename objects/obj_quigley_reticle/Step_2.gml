if (locked_on) {
	reticle_alpha -= 0.05;
	if (reticle_alpha == 0) {
		instance_destroy();
	}
} else {
	x = obj_soul.x;
	y = obj_soul.y;
	
	if (circle_scale > 0) {
		circle_scale -= 0.1;
	} else if (++reticle_image == 4) {
		with (obj_bullet_anser_star) {
			if (homing_ignore > 0) {
				homing_ignore--;
			} else if (!slowing_down && !homing) {
				slowing_down = true;
				target_x = other.x;
				target_y = other.y;
			}
		}
		
		locked_on = true;
		audio_play_sound(snd_reticle_locked_on, 1, false);
		
		call_later(audio_sound_length(snd_reticle_locked_on), time_source_units_seconds, function() {
			if (room == rm_battle) {  // Prevents the second sound from playing after the player dies
				audio_play_sound(snd_star_redirect, 1, false);
			}
		});
	}
}