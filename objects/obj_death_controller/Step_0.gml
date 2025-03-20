if (soul_moving) {
	soul_move_progress += 0.02;
	if (soul_move_progress == 1) {
		soul_moving = false;
		bright_soul_alpha = 0;
		
		alarm[2] = 15;
	}
}

if (game_over_fading) {
	game_over_alpha += 0.02;
	if (game_over_alpha == 1) {
		game_over_fading = false;
	}
}

music_building_up = false;

// This will remain undefined if music is undefined.
// This isn't an issue, since this variable is never used before the music starts.
var position;

if (!is_undefined(music) && !refusing) {
	position = audio_sound_get_track_position(music);
	music_building_up = (position >= music_buildup_start && position < music_drop);
}

if (music_building_up) {
	bright_soul_alpha = (position - music_buildup_start) / (music_drop - music_buildup_start);
}

if (!is_undefined(music)) {
	if (audio_sound_get_track_position(music) >= music_drop) {
		if (!pulsing && !refusing) {
			// The bright SOUL won't quite be at 100% alpha by the end of the buildup, so we need to fix that here.
			// The alpha will be close enough to 100% that doing this won't cause a noticeable jump.
			if (bright_soul_alpha < 1) {
				bright_soul_alpha = 1;
			}
	
			instance_create_layer(320, 270, "pulses", obj_soul_pulse);
			time_source_1 = time_source_create(time_source_game, music_beat_length * 4, time_source_units_seconds, function() {
				instance_create_layer(320, 270, "pulses", obj_soul_pulse);
			}, [], 15);
			time_source_start(time_source_1);
			
			call_later(music_beat_length * 1.5, time_source_units_seconds, function() {
				instance_create_layer(320, 270, "pulses", obj_soul_pulse);
				time_source_2 = time_source_create(time_source_game, music_beat_length * 4, time_source_units_seconds, function() {
					instance_create_layer(320, 270, "pulses", obj_soul_pulse);
				}, [], 15);
				time_source_start(time_source_2);
			});
	
			pulsing = true;
		}
	} else if (!music_building_up && !refusing && !pulsing) {
		music_color_shift_timer++;
		bright_soul_alpha = 1 - (dcos(music_color_shift_timer / music_color_shift_cycle_length % 1 * 360) / 2 + 0.5);
	}
}

if (ui_fading) {
	ui_alpha += 0.02;
	if (ui_alpha == 1) {
		ui_fading = false;
	}
}

if (dialogue_running) {
	dialogue_typewriter.step();
	
	if (global.keys.confirm_pressed && dialogue_typewriter.shown_chars == dialogue_typewriter.text_length) {
		if (++dialogue_page < array_length(global.death_text)) {
			dialogue_typewriter = new typewriter(format_basic, 25, false, snd_blip_gerson, true, noone, global.death_text[dialogue_page]);
		} else {
			dialogue_running = false;
			ui_fading = true;
		}
	}
}

if (ui_alpha == 1) {
	if ((global.keys.left_pressed || global.keys.right_pressed) && global.combat_demo_flags.completed_tutorial) {
		selection = !selection;
	} else if (global.keys.confirm_pressed) {
		if (selection == 0) {
			refusing = true;
		} else {
			quitting = true;
		}
		
		if (pulsing) {
			time_source_destroy(time_source_1);
			time_source_destroy(time_source_2);
		}
		
		audio_sound_gain(music, 0, 500);
	}
}

if (refusing) {
	if (ui_alpha > 0) {
		ui_alpha -= 0.05;
	}
	
	if (audio_sound_get_gain(music) == 0) {
		audio_stop_sound(music);
	}
	
	refuse_timer++;
	if (refuse_timer < 40) {
		if (bright_soul_alpha < 1) {
			bright_soul_alpha += 0.025;
		}
	} else if (refuse_timer == 40) {
		soul_sprite = spr_soul;
		audio_play_sound(snd_soul_break, 1, false);
	} else if (refuse_timer >= 70) {
		overlay_alpha += 0.03;
		if (overlay_alpha >= 1) {
			// TODO: Eventually, we should load the current SAVE point here.
			// For now, we need to handle Combat Demo logic.
			refusing = false;
			
			if (global.encounter.enemies[0].name == "Dummonstrous") {
				next_room = rm_tutorial;
			} else {
				// We need to reset the inventory, but it's nicer for the player if we don't reset anything
				// else.
				global.inventory = [
					global.items.lingonberry,
					global.items.creepy_cider,
					global.items.dog_bark,
					global.items.spiced_apple
				];
				
				global.player_created = false;
				global.quigley_anser_outcome = undefined;
				
				next_room = rm_trail_anser_quigley;
			}
			
			global.stats.current_health = global.stats.max_health;
			alarm[4] = 15;
		}
	}	
}

if (quitting) {
	overlay_alpha += 0.03;
	if (overlay_alpha >= 1) {
		quitting = false;
		
		global.stats.current_health = 50;
		next_room = rm_menu;
		alarm[4] = 15;
	}
}