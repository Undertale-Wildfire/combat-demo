enum challenges {
	trinketless,
	stress_hurts,
	patience,
	one_hit_wonder
}

// This shouldn't reset when entering submenus.
selection = 0;

// If we don't do this, the music won't play upon first entering the menu.
audio_stop_all();
music = audio_play_sound(mus_menu, 1, true);

fsm = new SnowState("main");

fsm.add("main", {
	enter: function() {
		if (fsm.get_previous_state() == "settings") {
			audio_stop_all();
			music = audio_play_sound(mus_menu, 1, true);
		}
	},
	step: function() {
		if (selection > 0 && global.keys.up_pressed && !global.keys.down_pressed) {
			selection--;
		}
		
		if (selection < 2 && global.keys.down_pressed && !global.keys.up_pressed) {
			selection++;
		}
		
		if (global.keys.confirm_pressed) {
			switch (selection) {
				case 0:
					if (global.combat_demo_flags.unlocked_challenges) {
						fsm.change("challenges");
					} else {
						global.challenge = undefined;
						fsm.change("fade");
					}
					
					break;
				
				case 1:
					global.challenge = undefined;
					fsm.change("fade");
					break;
				
				case 2:
					fsm.change("settings");
					audio_stop_all();
					audio_play_sound(mus_settings, 1, true);
					break;
			}
		}
	},
	draw: function() {
		draw_set_font(fnt_main);
		draw_set_halign(fa_center);
		draw_set_color(selection == 0 ? c_yellow : c_white);
		draw_text(320, 184, "Begin Game");
		draw_set_color(selection == 1 ? c_yellow : c_white);
		draw_text(320, 224, "Tutorial");
		draw_set_color(selection == 2 ? c_yellow : c_white);
		draw_text(320, 264, "Settings");
		
		draw_set_color(c_gray);
		draw_set_font(fnt_small);
		
		// This doesn't align right with 320...? I only noticed now that the text fills most of the screen
		// horizontally. I think this one's on GameMaker. This is one reason I dislike using actual font
		// files for pixel fonts; it seems alignment is often not quite as precise as I'd like.
		draw_text(321, 458, "UNDERTALE WILDFIRE COMBAT DEMO V1.12 (C) TEAM WILDFIRE 2024-2025");
		
		draw_set_halign(fa_left);
		draw_set_color(c_white);
	}
});

fsm.add("challenges", {
	enter: function() {
		challenge_options = ["Back", "No challenge", "Trinketless", "Stress Hurts", "Patience", "One Hit Wonder"];
		challenge_descriptions = [
			"Play the Combat Demo without any changes.",
			"Start combat with 0 Trinkets.",
			"Grazing drains HP.",
			"Start combat with only Support PLAYs, Magic Mirror, and Magic Cherry equipped.",
			"Equips a Trinket that reduces max HP to 1."
		];
		
		var completed_challenges = [
			true,  // To be viewing this menu, you have to have already completed the regular game.
			global.combat_demo_flags.completed_challenges.trinketless,
			global.combat_demo_flags.completed_challenges.stress_hurts,
			global.combat_demo_flags.completed_challenges.patience,
			global.combat_demo_flags.completed_challenges.one_hit_wonder
		];
		
		for (var i = 0; i < 5; i++) {
			challenge_descriptions[i] = wrap_formatted_text(challenge_descriptions[i], 20, false);
			
			repeat (6 - string_count("\n", challenge_descriptions[i])) {
				challenge_descriptions[i] += "\n";
			}
			
			if (completed_challenges[i]) {
				challenge_descriptions[i] += "{c,gr}Complete!";
			} else {
				challenge_descriptions[i] += "{c,gy}Incomplete...";
			}
		}
	},
	step: function() {
		if (selection > 0 && global.keys.up_pressed && !global.keys.down_pressed) {
			selection--;
		}
		
		if (selection < 5 && global.keys.down_pressed && !global.keys.up_pressed) {
			selection++;
		}
		
		if (global.keys.confirm_pressed) {
			if (selection == 0) {
				fsm.change("main");
			} else {
				// Challenges are stored in an enum in the same order as they appear in this menu, so this will result in
				// global.challenge being set to the correct challenge.
				global.challenge = (selection >= 2 ? selection - 2 : undefined);
				fsm.change("fade_challenges");
			}
		}
	},
	draw: function() {
		draw_set_font(fnt_main);
		draw_set_halign(fa_center);
		
		for (var i = 0; i < 6; i++) {
			draw_set_color(selection == i ? c_yellow : c_white);
			draw_text(128, 124 + i * 40, challenge_options[i]);
			draw_set_color(c_white);
		}
		
		if (selection >= 1) {
			draw_formatted_text(287, 114, format_basic, challenge_descriptions[selection - 1]);
		}
	}
});

// These functions have to be defined outside the fade states because there are two states that use them. Otherwise, all
// this code would be repeated twice unnecessarily. The only inefficiency with this approach is that we still check the
// selection variable in the fade_challenges state when doing so is not necessary - this is a non-issue, though. This feels
// a little messy to me, but it's not like this code will need to exist after the Combat Demo, so it'll do fine.
var fade_enter = function() {
	fade = instance_create_layer(0, 0, "system", obj_fade, {type: fade_types.out, frames: 30});
	black_timer = 30;
	audio_sound_gain(music, 0, 1000);
};

var fade_step = function() {
	if (!instance_exists(fade)) {
		if (!instance_exists(obj_black)) {
			instance_create_layer(0, 0, "system", obj_black);
		}
		
		if (--black_timer == 0) {
			global.stats = {
				love: 1,
				execution_points: 0,
				max_health: 50,
				current_health: 50,
				attack: 20,
				defense: 10,
				bravery: 0,  // Deprecated
				gold: 0
			};
			
			var unlocked_trinkets_length = array_length(global.unlocked_trinkets);
			for (var i = 0; i < unlocked_trinkets_length; i++) {
				global.unlocked_trinkets[i].equipped = false;
			}
			
			if (global.challenge == challenges.patience) {
				global.equipped_plays = [
					global.plays.deep_breath,
					global.plays.focus,
					global.plays.endure
				];
				
				global.trinkets.magic_mirror.equipped = true;
				global.trinkets.magic_cherry.equipped = true;
				global.equipped_trinkets = 2;
			} else {
				global.equipped_plays = [
					global.plays.strike,
					global.plays.roundhouse_kick,
					global.plays.deep_breath
				];
				
				if (global.challenge == challenges.one_hit_wonder) {
					global.stats.max_health = 1;
					global.stats.current_health = 1;
					
					array_insert(global.unlocked_trinkets, 0, global.trinkets.one_hit_wonder);
					global.trinkets.one_hit_wonder.equipped = true;
					global.equipped_trinkets = 1;
				} else {
					global.equipped_trinkets = 0;
				}
			}
			
			if (selection == 0 || fsm.get_previous_state() == "challenges") {
				global.inventory = [
					global.items.lingonberry,
					global.items.creepy_cider,
					global.items.dog_bark,
					global.items.spiced_apple
				];
				
				global.flags = {
					trail_mechanic_interacts: 0,
					trail_kiwi_interacts_pre_fight: 0,
					trail_kiwi_interacts_post_fight: 0,
					trail_plane_interacts: 0,
					trail_tools_interacts: 0,
					quigley_anser_attempted: false
				};
				
				global.player_created = false;
				global.quigley_anser_outcome = undefined;
				
				room_goto(rm_trail_anser_quigley);
			} else {
				global.inventory = [
					global.items.pancakes,
					global.items.hot_cocoa
				];
				
				room_goto(rm_tutorial);
			}
			
			audio_stop_all();
		}
	}
}

// We're only inheriting the draw() event here.
// The menu shouldn't be interactable while fading.
fsm.add_child("main", "fade", {
	enter: fade_enter,
	step: fade_step
});

fsm.add_child("challenges", "fade_challenges", {
	enter: fade_enter,
	step: fade_step
});

fsm.add("settings", {
	enter: function() {
		selected_setting = 0;
		changing_volume = false;
		changing_sfx_volume = false;
	},
	step: function() {
		if (selected_setting > 0 && global.keys.up_pressed && !global.keys.down_pressed) {
			selected_setting--;
		}
		
		if (selected_setting < 4 && global.keys.down_pressed && !global.keys.up_pressed) {
			selected_setting++;
		}
		
		if (global.keys.confirm_pressed) {
			switch (selected_setting) {
				case 0:
					fsm.change("main");
					break;
				
				case 1:
					if (++global.settings.window_scale > global.max_scale_integer) {
						global.settings.window_scale = 1;
					}
					
					window_set_size(640 * global.settings.window_scale, 480 * global.settings.window_scale);
					window_center();
					
					break;
				
				case 2:
					global.settings.integer_scaling = !global.settings.integer_scaling;
					if (window_get_fullscreen()) {
						if (global.settings.integer_scaling) {
							application_surface_draw_enable(false);
							display_set_gui_maximize(global.max_scale_integer, global.max_scale_integer, global.offset_x_integer, global.offset_y_integer);
						} else {
							application_surface_draw_enable(true);
							display_set_gui_maximize(global.max_scale, global.max_scale, global.offset_x, 0);
						}
					}
					
					break;
			}
			
			// Save setting changes to disk
			if (selected_setting == 1 || selected_setting == 2) {
				var file = file_text_open_write("settings.json");
				file_text_write_string(file, json_stringify(global.settings));
				file_text_close(file);
			}
		}
		
		// There's no "volume sensitivity" to change... the joke doesn't work with volume!
		if (selected_setting >= 3) {
			if (changing_volume) {
				if (global.keys.confirm_pressed || global.keys.cancel_pressed) {
					if (changing_sfx_volume) {
						// Play sound effect for reference
						audio_play_sound(snd_flicker, 1, false);
					}
					
					changing_volume = false;
					changing_sfx_volume = false;
					
					var file = file_text_open_write("settings.json");
					file_text_write_string(file, json_stringify(global.settings));
					file_text_close(file);
				} else if (selected_setting == 3) {
					var volume_old = global.settings.volume_music;
					
					if (global.keys.left_held && !global.keys.right_held && global.settings.volume_music > 0) {
						global.settings.volume_music -= 0.02;
					} else if (global.keys.right_held && !global.keys.left_held && global.settings.volume_music < 1) {
						global.settings.volume_music += 0.02;
					}
					
					if (global.settings.volume_music != volume_old) {
						global.settings.volume_music = clamp(global.settings.volume_music, 0, 1);
						audio_group_set_gain(audiogroup_default, global.settings.volume_music * 0.75, 0);
					}
				} else if (selected_setting == 4) {
					var volume_old = global.settings.volume_sfx;
					
					if (global.keys.left_held && !global.keys.right_held && global.settings.volume_sfx > 0) {
						global.settings.volume_sfx -= 0.02;
					} else if (global.keys.right_held && !global.keys.left_held && global.settings.volume_sfx < 1) {
						global.settings.volume_sfx += 0.02;
					}
					
					var changing_sfx_volume_old = changing_sfx_volume;
					changing_sfx_volume = (global.settings.volume_sfx != volume_old);
					
					if (changing_sfx_volume) {
						global.settings.volume_sfx = clamp(global.settings.volume_sfx, 0, 1);
						audio_group_set_gain(audiogroup_sfx, global.settings.volume_sfx, 0);
					} else if (changing_sfx_volume_old) {
						// Play sound effect for reference
						audio_play_sound(snd_flicker, 1, false);
					}
				}
			} else if (global.keys.confirm_pressed) {
				changing_volume = true;
			}
		}
	},
	draw: function() {
		draw_set_font(fnt_main);
		draw_set_halign(fa_center);
		draw_text_transformed(320, 22, "SETTINGS", 2, 2, 0);
		draw_set_halign(fa_left);
		
		draw_set_color(selected_setting == 0 ? c_yellow : c_white);
		draw_text(40, 88, "EXIT");
		
		draw_set_color(selected_setting == 1 ? c_yellow : c_white);
		draw_text(40, 148, "WINDOW SCALE");
		draw_text(274, 148, string(global.settings.window_scale) + "x");
		
		draw_set_color(selected_setting == 2 ? c_yellow : c_white);
		draw_text(40, 208, "INTEGER SCALING");
		draw_text(274, 208, global.settings.integer_scaling ? "ON" : "OFF");
		
		draw_set_color(selected_setting == 3 ? c_yellow : c_white);
		draw_text(40, 268, "MUSIC VOLUME");
		var slider_alpha = (selected_setting == 3 && changing_volume ? 1 : 0.6)
		draw_sprite_ext(spr_slider, 0, 274, 278, 2, 2, 0, c_green, slider_alpha);
		draw_set_alpha(slider_alpha);
		draw_set_color(c_yellow);
		var cursor_offset = global.settings.volume_music * 72;
		draw_rectangle(274 + cursor_offset, 274, 277 + cursor_offset, 293, false);
		draw_set_alpha(1);
		draw_set_color(selected_setting == 3 && changing_volume ? c_white : c_gray);
		draw_text(358, 268, $"{floor(global.settings.volume_music * 100)}%");
		
		draw_set_color(selected_setting == 4 ? c_yellow : c_white);
		draw_text(40, 328, "SFX VOLUME");
		slider_alpha = (selected_setting == 4 && changing_volume ? 1 : 0.6)
		draw_sprite_ext(spr_slider, 0, 274, 338, 2, 2, 0, c_green, slider_alpha);
		draw_set_alpha(slider_alpha);
		draw_set_color(c_yellow);
		cursor_offset = global.settings.volume_sfx * 72;
		draw_rectangle(274 + cursor_offset, 334, 277 + cursor_offset, 353, false);
		draw_set_alpha(1);
		draw_set_color(selected_setting == 4 && changing_volume ? c_white : c_gray);
		draw_text(358, 328, $"{floor(global.settings.volume_sfx * 100)}%");
		draw_set_color(c_white);
	}
});