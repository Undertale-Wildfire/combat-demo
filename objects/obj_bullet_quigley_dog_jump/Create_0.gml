event_inherited();
enemy = 0;

pulsing = false;
pulse_progress = 0;

barking = false;
bark_timer = 0;

walking = false;

jumping = false;
speed_x = 0.4;
speed_y = -5;

// Draw an alternate sad sprite if Anser is dead
function custom_draw() {
	if (global.encounter.enemies[1].state == enemy_states.dead) {
		var sad_sprite;
		switch (sprite_index) {
			case spr_bullet_quigley_dog: sad_sprite = spr_bullet_quigley_dog_sad; break;
			case spr_bullet_quigley_dog_bark: sad_sprite = spr_bullet_quigley_dog_sad_bark; break;
			case spr_bullet_quigley_dog_jump: sad_sprite = spr_bullet_quigley_dog_sad_jump; break;
			case spr_bullet_quigley_dog_walk: sad_sprite = spr_bullet_quigley_dog_sad_walk; break;
		}
		
		draw_sprite_ext(sad_sprite, image_index, x, y, image_xscale, image_yscale, image_angle, image_blend, image_alpha);
	} else {
		draw_self();
	}
}