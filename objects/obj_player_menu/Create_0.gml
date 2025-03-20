audio_play_sound(snd_menu_move, 1, false);

if (obj_player.has_follower) {
	submenus = ["PLAY", "TRNK", "ITEM", "STAT", "TALK"];
	submenus_length = 5;
} else {
	submenus = ["PLAY", "TRNK", "ITEM", "STAT"];
	submenus_length = 4;
}

// Values that shouldn't always be reset when entering their menu
selected_submenu = 0;
submenu_scroll = 0;

selected_trinket = 0;
trinket_scroll = 0;

selected_item = 0;

fsm = new SnowState("main");

fsm.add("main", {
	step: function() {
		if (global.keys.up_pressed && selected_submenu > 0) {
			if (--selected_submenu < submenu_scroll) {
				submenu_scroll--;
			}
			
			audio_play_sound(snd_menu_move, 1, false);
		}
		
		if (global.keys.down_pressed && selected_submenu < submenus_length - 1) {
			if (++selected_submenu - submenu_scroll > 2) {
				submenu_scroll++;
			}
			
			audio_play_sound(snd_menu_move, 1, false);
		}
		
		if (global.keys.confirm_pressed) {
			if (
				array_length(global.inventory) == 0 && selected_submenu == 2
				|| global.challenge == challenges.trinketless && selected_submenu == 1
				|| global.challenge == challenges.patience && selected_submenu <= 1
			) {
				audio_play_sound(snd_hurt, 1, false);
			} else {
				switch (selected_submenu) {
					case 0:
						fsm.change("play");
						break;
					
					case 1:
						selected_trinket = 0;
						trinket_scroll = 0;
						fsm.change("trnk");
						break;
					
					case 2:
						selected_item = 0;
						fsm.change("item");
						break;
					
					case 3:
						fsm.change("stat");
						break;
				}
				
				audio_play_sound(snd_select, 1, false);
			}
		}
		
		if (global.keys.cancel_pressed) {	
			instance_destroy();
		}
	},
	draw: function() {
		draw_sprite(spr_soul_small, 0, 56, 196 + (selected_submenu - submenu_scroll) * 36);
		
		if (selected_submenu == submenu_scroll + 2 && submenu_scroll < submenus_length - 3) {
			draw_sprite(spr_scroll_arrow, 0, 60, 292);
		} else if (selected_submenu == submenu_scroll && submenu_scroll > 0) {
			draw_sprite_ext(spr_scroll_arrow, 0, 60, 190, 1, -1, 0, c_white, 1);
		}
	}
});

fsm.add("play", {
	enter: function() {
		// The info box needs to be on the top half of the screen while the PLAY menu is selected to leave
		// room for the PLAY descriptions.
		info_box_y = 52;
		
		selected_play = 0;
		picking_new_play = false;
		
		equipped_plays_length = array_length(global.equipped_plays);
		unlocked_plays_length = array_length(global.unlocked_plays);
		
		error = false;
	},
	leave: function() {
		info_box_y = normal_info_box_y;
	},
	step: function() {
		if (picking_new_play) {
			if (global.keys.up_pressed && selected_new_play > 0 && !global.keys.down_pressed) {
				selected_new_play--;
				audio_play_sound(snd_menu_move, 1, false);
			} else if (global.keys.down_pressed && selected_new_play < allowed_new_plays_length - 1 && !global.keys.up_pressed) {
				selected_new_play++;
				audio_play_sound(snd_menu_move, 1, false);
			} else if (global.keys.confirm_pressed) {
				if (selected_play < equipped_plays_length) {
					global.equipped_plays[selected_play] = allowed_new_plays[selected_new_play];
				} else {
					array_push(global.equipped_plays, allowed_new_plays[selected_new_play]);
					equipped_plays_length++;
				}
				
				picking_new_play = false;
				audio_play_sound(snd_select, 1, false);
			} else if (global.keys.cancel_pressed) {
				picking_new_play = false;
				audio_play_sound(snd_menu_move, 1, false);
			}
		} else if (global.keys.up_pressed && selected_play > 0 && !global.keys.down_pressed) {
			selected_play--;
			error = false;
			audio_play_sound(snd_menu_move, 1, false);
		} else if (global.keys.down_pressed && selected_play < equipped_plays_length && selected_play < 3 && !global.keys.up_pressed) {
			selected_play++;
			error = false;
			audio_play_sound(snd_menu_move, 1, false);
		} else if (global.keys.confirm_pressed) {
			if (unlocked_plays_length > equipped_plays_length) {
				picking_new_play = true;
				selected_new_play = 0;
				
				allowed_new_plays = [];
				allowed_new_plays_length = 0;
				
				for (var i = 0; i < unlocked_plays_length; i++) {
					var skip = false;
					for (var j = 0; j < equipped_plays_length; j++) {
						if (j >= equipped_plays_length || global.equipped_plays[j] == global.unlocked_plays[i]) {
							skip = true;
							break;
						}
					}
					
					if (!skip) {
						array_push(allowed_new_plays, global.unlocked_plays[i]);
						allowed_new_plays_length++;
					}
				}
				
				audio_play_sound(snd_select, 1, false);
			} else {
				audio_play_sound(snd_hurt, 1, false);
			}
		} else if (global.keys.cancel_pressed) {
			var has_attack = false;
			for (var i = 0; i < equipped_plays_length; i++) {
				if (global.equipped_plays[i].type == play_types.attack) {
					has_attack = true;
					break;
				}
			}
			
			if (has_attack) {
				fsm.change("main");
				audio_play_sound(snd_menu_move, 1, false);
			} else {
				error = true;
				audio_play_sound(snd_hurt, 1, false);
			}
		}
	},
	draw: function() {
		draw_rectangle(188, 52, 435, 301, false);
		draw_set_color(c_black);
		draw_rectangle(194, 58, 429, 295, false);
		draw_set_color(c_white);
		
		for (var i = 0; i < 4; i++) {
			if (i < equipped_plays_length) {
				draw_sprite([spr_play_attack, spr_play_support, spr_play_team][global.equipped_plays[i].type], 0, 252, 97 + i * 32);
				draw_text(276, 81 + i * 32, global.equipped_plays[i].short_name);
			} else {
				if (i == equipped_plays_length) {
					draw_set_color(c_gray);
					draw_text(276, 81 + i * 32, "[Add new]");
					draw_set_color(c_white);
				}
			}
		}
		
		if (picking_new_play) {
			draw_rectangle(450, 52, 576, 95 + allowed_new_plays_length * 20, false);
			draw_set_color(c_black);
			draw_rectangle(456, 58, 570, 89 + allowed_new_plays_length * 20, false);
			draw_set_color(c_white);
			
			draw_set_font(fnt_dialogue_battle);
			draw_formatted_text(466, 65, format_bubble, "New PLAY:");
			
			for (var i = 0; i < allowed_new_plays_length; i++) {
				draw_formatted_text(
					479,
					85 + i * 20,
					format_bubble,
					["{c,o}", "{c,lb}"][allowed_new_plays[i].type] + allowed_new_plays[i].short_name
				);
			}
			
			draw_sprite_ext(spr_soul_small, 0, 467, 90 + selected_new_play * 20, 0.5, 0.5, 0, c_white, 1);
		} else {
			draw_sprite(spr_soul_small, 0, 208, 88 + selected_play * 32);
		}
		
		// Don't draw the description box if the Attack PLAY error message is displaying
		if ((selected_play < equipped_plays_length || picking_new_play) && !instance_exists(obj_cutscene)) {
			if (error) {
				draw_rectangle(32, 322, 392, 367, false);
				draw_set_color(c_black);
				draw_rectangle(38, 328, 386, 361, false);
				draw_set_color(c_white);
				
				draw_formatted_text(48, 336, format_bubble, "* You need at least one {c,o}Attack{c,w} PLAY!");
			} else {
				var inspected_play = picking_new_play ? allowed_new_plays[selected_new_play] : global.equipped_plays[selected_play];
				var info_box_y2 = 347 + 20 * (string_count("\n", inspected_play.description) + 2);
				
				draw_rectangle(32, 322, 606, info_box_y2, false);
				draw_set_color(c_black);
				draw_rectangle(38, 328, 600, info_box_y2 - 6, false);
				draw_set_color(c_white);
				
				draw_formatted_text(48, 336, format_bubble, get_play_info_text(inspected_play));
			}
		}
	}
});

fsm.add("trnk", {
	enter: function() {
		trinkets_length = array_length(global.unlocked_trinkets);
		picking_action = false;
	},
	step: function() {
		if (picking_action) {
			if (global.keys.left_pressed && selected_action == 1 && !global.keys.right_pressed) {
				selected_action = 0;
				audio_play_sound(snd_menu_move, 1, false);
			} else if (global.keys.right_pressed && selected_action == 0 && !global.keys.left_pressed) {
				selected_action = 1;
				audio_play_sound(snd_menu_move, 1, false);
			} else if (global.keys.confirm_pressed) {
				var trinket = global.unlocked_trinkets[selected_trinket];
				if (selected_action == 0) {
					if (trinket.equipped) {
						if (trinket.name == "One Hit Wonder") {
							audio_play_sound(snd_hurt, 1, false);
						} else {
							trinket.equipped = false;
							global.equipped_trinkets--;
							picking_action = false;
							
							audio_play_sound(snd_select, 1, false);
						}
					} else if (global.equipped_trinkets < global.trinket_slots) {
						trinket.equipped = true;
						global.equipped_trinkets++;
						picking_action = false;
						
						audio_play_sound(snd_item, 1, false);
					} else {
						audio_play_sound(snd_hurt, 1, false);
					}
				} else {
					trinket_text = array_concat(
						// ["\"" + trinket.name + "\" -{a,e} " + ["Common", "Uncommon", "{c,y}Rare{c,w}", "{c,y}{e,w}Legendary{e,n}{c,w}"][trinket.rarity] + "\n" + trinket.flavor],
						["\"" + trinket.name + "\" -{a,e} Trinket\n" + trinket.flavor],
						trinket.description
					);
					
					fsm.change("trinket_dialogue");
				}
			} else if (global.keys.cancel_pressed) {
				picking_action = false;
			}
		} else if (global.keys.up_pressed && selected_trinket > 0 && !global.keys.down_pressed) {
			if (--selected_trinket < trinket_scroll) {
				trinket_scroll--;
			}
			
			audio_play_sound(snd_menu_move, 1, false);
		} else if (global.keys.down_pressed && selected_trinket < trinkets_length - 1 && !global.keys.up_pressed) {
			if (++selected_trinket - trinket_scroll > 7) {
				trinket_scroll++;
			}
			
			audio_play_sound(snd_menu_move, 1, false);
		} else if (global.keys.confirm_pressed) {
			picking_action = true;
			selected_action = 0;
			audio_play_sound(snd_select, 1, false);
		} else if (global.keys.cancel_pressed) {
			fsm.change("main");
			audio_play_sound(snd_menu_move, 1, false);
		}
	},
	draw: function() {
		draw_rectangle(188, 52, 533, 413, false);
		draw_set_color(c_black);
		draw_rectangle(194, 58, 527, 407, false);
		draw_set_color(c_white);
		
		for (var i = trinket_scroll; i < trinkets_length && i < trinket_scroll + 8; i++) {
			draw_set_color(global.unlocked_trinkets[i].equipped ? c_yellow : c_white);
			draw_text(232, 81 + (i - trinket_scroll) * 32, global.unlocked_trinkets[i].name);
		}
		
		var equipped = global.unlocked_trinkets[selected_trinket].equipped;
		draw_set_color((
			!equipped && global.equipped_trinkets == global.trinket_slots
			|| equipped && global.unlocked_trinkets[selected_trinket].name == "One Hit Wonder"
		) ? c_gray : c_white);
		draw_text(255, 361, equipped ? "UNEQUIP" : "EQUIP");
		draw_set_color(c_white);
		draw_text(413, 361, "INFO");
		
		if (picking_action) {
			draw_sprite(spr_soul_small, 0, selected_action ? 389 : 231, 368);
		} else {
			draw_sprite(spr_soul_small, 0, 208, 88 + (selected_trinket - trinket_scroll) * 32);
			
			if (selected_trinket == trinket_scroll + 7 && trinket_scroll < trinkets_length - 8) {
				draw_sprite(spr_scroll_arrow, 0, 212, 336);
			} else if (selected_trinket == trinket_scroll && trinket_scroll > 0) {
				draw_sprite_ext(spr_scroll_arrow, 0, 212, 82, 1, -1, 0, c_white, 1);
			}
		}
		
		draw_rectangle(548, 52, 631, 135, false);
		draw_set_color(c_black);
		draw_rectangle(554, 58, 625, 129, false);
		draw_set_color(c_white);
		
		draw_sprite_ext(spr_trinket_icons, global.unlocked_trinkets[selected_trinket].icon, 590, 94, 2, 2, 0, c_white, 1);
		
		draw_rectangle(548, 142, 631, 189, false);
		draw_set_color(c_black);
		draw_rectangle(554, 148, 625, 183, false);
		draw_set_color(c_white);
		
		draw_text(564, 149, $"{global.equipped_trinkets} / {global.trinket_slots}");
	}
});

fsm.add("trinket_dialogue", {
	enter: function() {
		cutscene = cutscene_init().add(new ev_dialogue_basic(trinket_text)).start();
	}
});

fsm.add("item", {
	enter: function() {
		picking_action = false;
		inventory_length = array_length(global.inventory);
	},
	step: function() {
		if (inventory_length == 0) {
			if (global.keys.cancel_pressed) {
				fsm.change("main");
				audio_play_sound(snd_menu_move, 1, false);
			}
			
			return;
		}
		
		if (picking_action) {
			if (global.keys.left_pressed && selected_action > 0 && !global.keys.right_pressed) {
				selected_action--;
				audio_play_sound(snd_menu_move, 1, false);
			} else if (global.keys.right_pressed && selected_action < 2 && !global.keys.left_pressed) {
				selected_action++;
				audio_play_sound(snd_menu_move, 1, false);
			} else if (global.keys.confirm_pressed) {
				switch (selected_action) {
					case 0:
						item_text = use_item(selected_item);
						break;
					
					case 1:
						item_text = [];
						array_copy(item_text, 0, global.inventory[selected_item].description, 0, array_length(global.inventory[selected_item].description));
						break;
					
					case 2:
						item_text = [];
						array_copy(item_text, 0, global.inventory[selected_item].drop_text, 0, array_length(global.inventory[selected_item].drop_text));
						array_delete(global.inventory, selected_item, 1);
						break;
				}
				
				fsm.change("item_dialogue");
			} else if (global.keys.cancel_pressed) {
				picking_action = false;
			}
		} else if (global.keys.up_pressed && selected_item > 0 && !global.keys.down_pressed) {
			selected_item--;
			audio_play_sound(snd_menu_move, 1, false);
		} else if (global.keys.down_pressed && selected_item < inventory_length - 1 && !global.keys.up_pressed) {
			selected_item++;
			audio_play_sound(snd_menu_move, 1, false);
		} else if (global.keys.confirm_pressed) {
			picking_action = true;
			selected_action = 0;
			audio_play_sound(snd_select, 1, false);
		} else if (global.keys.cancel_pressed) {
			fsm.change("main");
			audio_play_sound(snd_menu_move, 1, false);
		}
	},
	draw: function() {
		draw_rectangle(188, 52, 533, 413, false);
		draw_set_color(c_black);
		draw_rectangle(194, 58, 527, 407, false);
		draw_set_color(c_white);
		
		for (var i = 0; i < inventory_length; i++) {
			draw_text(232, 81 + i * 32, global.inventory[i].name);
		}
		
		draw_text(232, 361, "USE");
		draw_text(328, 361, "INFO");
		draw_text(442, 361, "DROP");
		
		if (picking_action) {
			draw_sprite(spr_soul_small, 0, [208, 304, 418][selected_action], 368);
		} else {
			draw_sprite(spr_soul_small, 0, 208, 88 + selected_item * 32);
		}
	}
});

fsm.add("item_dialogue", {
	enter: function() {
		cutscene = cutscene_init().add(new ev_dialogue_basic(item_text)).start();
	}
});

fsm.add("stat", {
	enter: function() {
		equipped_trinket_names = [];
		repeat (global.trinket_slots) {
			array_push(equipped_trinket_names, "<NONE>");
		}
		
		var unlocked_trinkets_length = array_length(global.unlocked_trinkets);
		var equipped_trinket_index = 0;
		
		for (var i = 0; i < unlocked_trinkets_length; i++) {
			if (global.unlocked_trinkets[i].equipped) {
				equipped_trinket_names[equipped_trinket_index++] = global.unlocked_trinkets[i].name;
			}
		}
	},
	step: function() {
		if (global.keys.cancel_pressed) {
			fsm.change("main");
			audio_play_sound(snd_menu_move, 1, false);
		}
	},
	draw: function() {
		draw_rectangle(188, 52, 533, 469, false);
		draw_set_color(c_black);
		draw_rectangle(194, 58, 527, 463, false);
		draw_set_color(c_white);
		
		// TODO: There will be more than 2 Trinket slots eventually; figure out a way to show that here
		draw_text(216, 85, "\"Riley\"");
		draw_text(216, 145, $"LV  {global.stats.love}");
		draw_text(216, 177, $"HP  {global.stats.current_health} / {global.stats.max_health}");
		draw_text(216, 241, $"AT  {global.stats.attack}");
		draw_text(216, 273, $"DF  {global.stats.defense}");
		draw_text(384, 241, $"EXP: {global.stats.execution_points}");
		draw_text(384, 273, $"NEXT: {global.required_exp[global.stats.love - 1]}");
		draw_text(216, 333, $"TRNK A: {equipped_trinket_names[0]}");
		draw_text(216, 365, $"TRNK B: {equipped_trinket_names[1]}");
		draw_text(216, 405, $"GOLD: {global.stats.gold}");
	}
});