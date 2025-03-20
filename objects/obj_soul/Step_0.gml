if (obj_battle_controller.fsm.get_current_state() == "attack") {
	var move_speed = global.keys.cancel_held ? 2 : 4;

	if (global.keys.right_held) {
		x += move_speed;
	}

	if (global.keys.left_held) {
		x -= move_speed;
	}

	if (global.keys.down_held) {
		y += move_speed;
	}

	if (global.keys.up_held) {
		y -= move_speed;
	}
	
	if (bbox_left < obj_battle_controller.box.x1 + 5) {
		x = obj_battle_controller.box.x1 + 13;
	}

	if (bbox_right > obj_battle_controller.box.x2 - 5) {
		x = obj_battle_controller.box.x2 - 12;
	}

	if (bbox_top < obj_battle_controller.box.y1 + 5) {
		y = obj_battle_controller.box.y1 + 13;
	}

	if (bbox_bottom > obj_battle_controller.box.y2 - 5) {
		y = obj_battle_controller.box.y2 - 12;
	}
}

if (inv_timer > 0) {
	inv_timer--;
	if (inv_timer == 0) {
		image_speed = 0;
		image_index = 0;
	}
} else if (visible) {
	var moving = (x != xprevious || y != yprevious);
	
	// We can't use instance_place() because of the dangerous check.
	var standard_bullet = noone;
	with (obj_bullet) {
		if (dangerous && place_meeting(x, y, obj_soul)) {
			standard_bullet = id;
			break;
		}
	}
	
	// I don't see the need (at least for now) for non-dangerous blue/orange bullets.
	// If they are needed in the future, though, it won't be a difficult addition.
	var blue_bullet = instance_place(x, y, obj_bullet_blue);
	var orange_bullet = instance_place(x, y, obj_bullet_orange);
	
	// Find the bullet the SOUL was hit by (standard > blue > orange)
	// The AT of this bullet's owner is used.
	var bullet = noone;
	if (standard_bullet != noone) {
		bullet = standard_bullet;
	} else if (blue_bullet != noone && moving) {
		bullet = blue_bullet;
	} else if (orange_bullet != noone && !moving) {
		bullet = orange_bullet;
	}
	
	if (bullet != noone) {
		if (bullet.instant_kill) {
			// This isn't generally used for normal attacks (that would be pretty bad design!); instead, it's
			// used for fake "attacks" that roughly serve the purpose of a cutscene.
			global.stats.current_health = 0;
		} else if (grace_turns > 0) {
			grace_turns--;
		} else {
			var damage = floor(
				max(1, global.encounter.enemies[bullet.enemy].attack - (obj_battle_controller.creepy_cider ? global.stats.defense * 0.8 : global.stats.defense))
				* (1 + (obj_battle_controller.focus > 0) * 0.25 + (obj_battle_controller.endure > 0) * 0.25)
			);
			
			global.stats.current_health -= damage;
			obj_battle_controller.times_hurt++;
		}
		
		if (global.stats.current_health <= 0) {
			global.death_x = x;
			global.death_y = y;
			global.death_text = obj_battle_controller.enemy_turn.death_text;
			global.battle_return_room_reset = true;
			
			room_goto(rm_death);
		} else {
			obj_battle_controller.bp = min(obj_battle_controller.bp + 2 + global.stats.bravery div 4, 100);
			obj_battle_controller.times_hit_per_enemy[bullet.enemy]++;
			
			if (obj_battle_controller.deep_breath) {
				obj_battle_controller.deep_breath = false;
				call_cancel(obj_battle_controller.bp_heals);
			}
			
			image_speed = 1;
			inv_timer = 40;
			
			obj_camera.shake_x = 2;
			obj_camera.shake_y = 2;
			obj_camera.alarm[0] = 1;
			
			audio_play_sound(snd_hurt, 1, false);
		}
	}
}

var green_bullet = instance_place(x, y, obj_bullet_green);
if (green_bullet != noone) {
	global.stats.current_health = min(global.stats.current_health + ceil(global.stats.max_health * 0.05), global.stats.max_health);
	instance_destroy(green_bullet);
	audio_play_sound(snd_power, 1, false);
}

if (graze_timer > 0) {
	graze_timer--;
}

if (inv_timer == 0 && visible) {
	mask_index = spr_graze_hitbox;
	var old_image = image_index;
	image_index = global.stats.bravery;
	
	var graze_sound = false;
	with (obj_bullet) {
		if (dangerous && place_meeting(x, y, other)) {
			var bp_gain = (2 + global.stats.bravery) * (obj_battle_controller.focus > 0 ? 2.25 : 1);
			if (grazed) {
				obj_battle_controller.bp += bp_gain / 30;
				if (global.challenge == challenges.stress_hurts) {
					global.stats.current_health -= bp_gain / 30;
				}
				
				// This code is pretty much straight from Deltarune. I don't know exactly why it works the way
				// it does, but I'm just going to go with it.
				with (other) {
					if (graze_timer >= 0 && graze_timer < 4) {
		                graze_timer = 3;
					}
					
		            if (graze_timer < 2) {
		                graze_timer = 2;
					}
				}
			} else {
				grazed = true;
				obj_battle_controller.bp += bp_gain;
				
				if (global.challenge == challenges.stress_hurts) {
					global.stats.current_health -= bp_gain;
				}
				
				other.graze_timer = 10;
				graze_sound = true;
			}
			
			if (obj_battle_controller.bp > 100) {
				obj_battle_controller.bp = 100;
			}
			
			if (global.challenge == challenges.stress_hurts && global.stats.current_health <= 0) {
				global.death_x = x;
				global.death_y = y;
				global.death_text = obj_battle_controller.enemy_turn.death_text;
				global.battle_return_room_reset = true;
				
				room_goto(rm_death);
			}
		}
	}
	
	if (graze_sound) {
		audio_play_sound(snd_graze, 1, false);
	}
	
	mask_index = spr_soul;
	image_index = old_image;
}