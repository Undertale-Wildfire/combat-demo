enum battle_fade_types {
	screen,  // Fade the whole screen in. This is the most common case.
	ui  // Fade only the battle UI in. Everything else (enemies, backgrounds, etc) will be immediately visible.
}

enum enemy_states {
	alive,
	knocked_down,
	spared,
	dead
}

// For box transformations
enum box_metrics {
	x1,
	y1,
	x2,
	y2
}

// Types of things the player can do on their turn
// (This is passed to the enemy_turn() function to allow enemies to react to your actions.)
enum player_action_types {
	play,
	act,
	item,
	spare,
	flee_fail
}

// Ways the battle can be manually ended in the player's favor
enum win_types {
	immediate,  // The battle ends immediately, and the enemy does not get its turn.
	after_cutscene  // The battle ends after the enemy cutscene.
}

ui_alpha = 1;
if (global.battle_fade_type == battle_fade_types.screen) {
	instance_create_layer(0, 0, "system", obj_fade, {type: fade_types.in, frames: 5, draw_soul: true});
} else {
	ui_alpha = 0;
}

ui_surface = undefined;

// Get currently equipped trinkets
// (These aren't normally stored in an array, but we have to put them in one to display the icons.)
equipped_trinkets = [];
equipped_trinkets_animations = [];
equipped_trinkets_length = 0;

var unlocked_trinkets_length = array_length(global.unlocked_trinkets);
for (var i = 0; i < unlocked_trinkets_length; i++) {
	var trinket = global.unlocked_trinkets[i];
	if (trinket.equipped) {
		array_push(equipped_trinkets, trinket);
		array_push(equipped_trinkets_animations, {
			animating: false,
			progress: 0
		});
		
		equipped_trinkets_length++;
	}
}

function trinket_pulse(trinket) {
	for (var i = 0; i < equipped_trinkets_length; i++) {
		if (equipped_trinkets[i] == trinket) {
			equipped_trinkets_animations[i].animating = true;
			equipped_trinkets_animations[i].progress = 0;
			break;
		}
	}
}

// Set up enemies
enemies_length = array_length(global.encounter.enemies);
for (var i = 0; i < enemies_length; i++) {
	var enemy = global.encounter.enemies[i];
	enemy.instance = instance_create_layer(enemy._x, enemy._y, "enemies", enemy.object, {enemy: enemy});
	enemy.current_health = enemy.max_health;
	enemy.state = enemy_states.alive;
	
	if (global.trinkets.blinding_powder.equipped) {
		enemy.vulnerable = 2;
		trinket_pulse(global.trinkets.blinding_powder);
	} else {
		enemy.vulnerable = 0;
	}
	
	// Turns of Vulnerable to be applied on the next turn.
	// These need to be stored separately or you will always gain one less turn of Vulnerable than intended.
	enemy.pending_vulnerable = 0;
}

// Hardcoded values for the buttons (why aren't they evenly spaced, Toby?)
button_sprites = [spr_button_play, spr_button_act, spr_button_item, spr_button_mercy];
button_positions = [32, 185, 345, 500];

// This is the battle box, which is used for both the dialogue and battle boxes. An animation plays to
// transition between them.
dialogue_box = {x1: 32, y1: 250, x2: 606, y2: 389};
box = {x1: dialogue_box.x1, y1: dialogue_box.y1, x2: dialogue_box.x2, y2: dialogue_box.y2};

// Bravery point values
bp = 0;
old_bp = 0;
visible_bp = 0;
last_visible_bp = 0;
bp_animation_progress = 0;

// These values don't change between state transitions, so they need to be defined here.
selected_button = 0;
selected_target = 0;

first_turn = true;

// This chance represents a multiple of 10%. It increases by 10% each turn.
// It should be 50% on the first turn, so we initialize it to 40% here so when it is increased on that
// turn it ends up at 50%.
flee_chance = 4;

// Player turn data, returned from .player_turn()
player_turn = global.encounter.player_turn();

// Transparent overlay to make bullets outside the box more visible
overlay_alpha = 0;

// Item special effects
creepy_cider = false;
spiced_apple = 0;

// PLAY special effects
sucker_punch = false;
trip = false;
deep_breath = false;
focus = 0;
endure = 0;

// Player actions since the last enemy turn
player_actions = [];

// Boosts for Magic Mirror damage
// (if Magic Mirror is not equipped, these boosts will still take effect)
reflect_boosts = [];

// Battle winnings
earned_exp = 0;
earned_gold = 0;

// Options accessible through the debug console
enemy_cutscenes_enabled = true;
enemy_attacks_enabled = true;
forced_attack = undefined;

function check_for_win() {
	var win = true;
	for (var i = 0; i < enemies_length; i++) {
		if (
			(!player_turn.win_check.spared || global.encounter.enemies[i].state != enemy_states.spared)
			&& (!player_turn.win_check.dead || global.encounter.enemies[i].state != enemy_states.dead)
		) {
			win = false;
			break;
		}
	}
	
	return win;
}

// Returns to the base buttons state, and handles per-player turn logic.
// Only called for turns after the first one.
function start_player_turn(win_check = true) {
	var state = fsm.get_current_state();
	
	var all_incapacitated = true;
	for (var i = 0; i < enemies_length; i++) {
		if (global.encounter.enemies[i].state == enemy_states.alive) {
			all_incapacitated = false;
			break;
		}
	}
	
	if (all_incapacitated && state != "enemy_cutscene" && state != "attack" && state != "magic_mirror") {
		var play = global.equipped_plays[selected_play];
		if (play.type == play_types.attack) {
			array_push(player_actions, {type: player_action_types.play, target: selected_target, play: play, miss: miss});
		} else {
			array_push(player_actions, {type: player_action_types.play, play: play});
		}
		
		start_enemy_turn();
		return;
	}
	
	new_box = dialogue_box;
	transform_reverse = true;
	next_state = (win_check && check_for_win() ? "win" : "buttons");
	
	if (next_state == "buttons") {
		for (var i = 0; i < enemies_length; i++) {
			var enemy = global.encounter.enemies[i];
			
			if (enemy.vulnerable > 0) {
				enemy.vulnerable--;
			}
			
			if (enemy.pending_vulnerable > 0) {
				enemy.vulnerable += enemy.pending_vulnerable;
				enemy.pending_vulnerable = 0;
			}
			
			player_turn = global.encounter.player_turn();
		}
		
		if (spiced_apple > 0) {
			global.stats.current_health += 10;
			if (global.stats.current_health > global.stats.max_health) {
				global.stats.current_health = global.stats.max_health;
			}
			
			spiced_apple--;
			audio_play_sound(snd_power, 1, false);
		}
		
		player_actions = [];
		reflect_boosts = [];
		
		if (all_incapacitated) {
			bp += 10;
			if (bp > 100) {
				bp = 100;
			}
		}
	}
	
	fsm.change("transform_box");
}

function start_enemy_turn() {
	var win = check_for_win();
	
	if (!win) {
		enemy_turn = global.encounter.enemy_turn(player_actions);
		if (enemy_turn.win_type == win_types.immediate) {
			win = true;
		} else if (!is_undefined(forced_attack)) {
			enemy_turn.attack = forced_attack;
		}
	}
	
	if (win || is_undefined(enemy_turn.attack) || !enemy_attacks_enabled) {
		new_box = dialogue_box;
		transform_reverse = true;
		next_state = (win ? "win" : (is_undefined(enemy_turn.cutscene) || !enemy_cutscenes_enabled ? "buttons" : "enemy_cutscene"));
	} else {
		new_box = enemy_turn.attack.box;
		transform_reverse = false;
		next_state = "enemy_cutscene";
	}
	
	if (next_state == "buttons") {
		end_enemy_turn();
	}
	
	fsm.change("transform_box");
}

// Reset/decrement enemy turn-based values/counters
function end_enemy_turn() {
	if (first_turn) {
		first_turn = false;
	}
			
	sucker_punch = false;
	trip = false;
	deep_breath = false;
			
	if (focus) {
		focus--;
	}
			
	if (endure) {
		endure--;
	}
}

// Draws info boxes for PLAYs/items.
function draw_info(info, expanded) {
	if (expanded) {
		var info_box_y1 = 221 - (string_count("\n", info) + 1) * 20;
		draw_rectangle(box.x1, info_box_y1, box.x2, 244, false);
		draw_set_color(c_black);
		draw_rectangle(box.x1 + 5, info_box_y1 + 5, box.x2 - 5, 239, false);
		draw_set_color(c_white);
		
		draw_formatted_text(box.x1 + 15, info_box_y1 + 13, format_bubble, info);
	} else {
		draw_rectangle(box.x1, 201, box.x1 + 200, 244, false);
		draw_set_color(c_black);
		draw_rectangle(box.x1 + 5, 206, box.x1 + 195, 239, false);
		draw_set_color(c_white);
		
		draw_formatted_text(box.x1 + 15, 214, format_bubble, "* [C] to show info.");
	}
}

function use_play() {
	var play = global.equipped_plays[selected_play];
	
	if (play.name != "Sucker Punch" || !first_turn) {
		bp -= play.cost;
	}
	
	if (variable_struct_exists(play, "effect")) {
		play.effect();
	}
	
	if (variable_struct_exists(play, "minigame")) {
		new_box = play.minigame.box;
		transform_reverse = false;
		next_state = play.minigame.state;
		fsm.change("transform_box");
	} else {
		array_push(player_actions, {type: player_action_types.play, target: selected_target, play: play});
		
		if (play.name == "Endure") {
			start_player_turn();
		} else {
			start_enemy_turn();
		}
	}
}

function draw_minigame_timer(remaining, maximum) {
	if (remaining > 0) {
		draw_rectangle(box.x1, box.y1 - 54, box.x1 + 49, box.y1 - 5, false);
		draw_set_color(c_black);
		draw_rectangle(box.x1 + 5, box.y1 - 49, box.x1 + 44, box.y1 - 10, false);
		draw_set_color(c_white);
		
		draw_sprite_ext(spr_minigame_timer, ceil(remaining / maximum * 8) - 1, box.x1 + 9, box.y1 - 45, 2, 2, 0, c_white, 1);
	}
}

// Handles the animations that play after a minigame (like the slash in Undertale).
function play_animation() {
	if (is_undefined(animation_sprite)) {
		if (enemy.invulnerable) {
			instance_create_layer(enemy.instance.x, enemy.instance.damage_bar_y, "bullets", obj_miss);
		} else {
			instance_create_layer(
				enemy.instance.x,
				enemy.instance.damage_bar_y,
				"bullets",
				obj_damage_bar,
				{enemy: enemy, damage: damage, critical: (fsm.get_current_state() == "minigame_combo" ? critical : false)}
			);
		}
		
		animating = false;
	} else {
		animation_image += 0.4;  // 2.5 frames per image = 12 FPS
		if (animation_image >= sprite_get_number(animation_sprite)) {
			if (animation_sprite == spr_play_impact) {
				animation_sprite = undefined;
			} else {
				animation_sprite = spr_play_impact;
				animation_image = 0;
			}
		}
	}
}

// Gets the player's AT, taking factors like items into account.
function get_player_attack() {
	if (creepy_cider) {
		return floor(global.stats.attack * 1.2);
	} else {
		return global.stats.attack;
	}
}

fsm = new SnowState("buttons");

fsm.add("buttons", {
	enter: function() {
		flavor_typewriter = new typewriter(format_battle, 32, true, snd_blip_battle, true, noone, player_turn.flavor_text);
		
		if (flee_chance < 10) {
			flee_chance++;
		}
		
		obj_soul.x = button_positions[selected_button] + 16;
		obj_soul.y = 454;
		obj_soul.visible = true;
	},
	step: function() {
		var old_selected_button = selected_button;
		
		if (global.keys.right_pressed) {
			selected_button = (selected_button + 1) % 4;
		}
		
		if (global.keys.left_pressed) {
			// GameMaker's modulus doesn't work with negative numbers in the way needed for this, so
			// we just need to manually check if we need to wrap back around instead.
			// This happens a few more times in this event, since all the menus exhibit the same
			// wrapping behavior.
			if (selected_button == 0) {
				selected_button = 3;
			} else {
				selected_button--;
			}
		}
		
		if (selected_button != old_selected_button) {
			obj_soul.x = button_positions[selected_button] + 16;
			audio_play_sound(snd_menu_move, 1, false);
		}
		
		if (global.keys.confirm_pressed) {
			switch (selected_button) {
				case 0:
					selected_play = 0;  // Should only be reset when entering from buttons
					fsm.change("pick_play");
					
					// Discount PLAYs by 20% for the Comfort Wraps trinket
					if (global.trinkets.comfort_wraps.equipped) {
						play_discounts = [];
						for (var i = 0; i < equipped_plays_length; i++) {
							var discount = floor(global.equipped_plays[i].cost * 0.2);
							global.equipped_plays[i].cost -= discount;
							array_push(play_discounts, discount);
						}
						
						trinket_pulse(global.trinkets.comfort_wraps);
					}
					
					break;
				
				case 1: fsm.change("pick_target"); break;
				
				case 2:
					if (array_length(global.inventory) > 0) {
						fsm.change("pick_item");
					} else {
						audio_play_sound(snd_hurt, 1, false);
					}
					
					break;
				
				case 3: fsm.change("mercy"); break;
			}
			
			if (fsm.get_current_state() != "buttons") {
				audio_play_sound(snd_select, 1, false);
			}
		}
		
		flavor_typewriter.step();
	},
	draw: function() {
		flavor_typewriter.draw(52, 271);
	}
});

fsm.add("pick_play", {
	enter: function() {
		info_visible = false;
		
		equipped_plays_length = array_length(global.equipped_plays);
		var base_column_height = equipped_plays_length div 2;
		column_heights = [base_column_height + equipped_plays_length % 2, base_column_height];
		
		play_availabilities = [];
		for (var i = 0; i < equipped_plays_length; i++) {
			array_push(play_availabilities, variable_struct_exists(global.equipped_plays[i], "requirement") ? global.equipped_plays[i].requirement() : true);
		}
		
		obj_soul.x = 72 + selected_play % 2 * 264;
		obj_soul.y = 286 + selected_play div 2 * 32;
	},
	step: function() {
		var column = selected_play % 2;
		var old_selected_play = selected_play;
		
		// There are only two columns, so left and right do the same thing
		if (global.keys.right_pressed || global.keys.left_pressed) {
			if (column == 0 && selected_play < equipped_plays_length - 1) {
				selected_play++;
			} else if (column == 1) {
				selected_play--;
			}
		}
		
		if (global.keys.down_pressed) {
			if (selected_play < equipped_plays_length - 2) {
				selected_play += 2;
			} else {
				selected_play = selected_play % 2;
			}
		}
		
		if (global.keys.up_pressed) {
			if (selected_play > 1) {
				selected_play -= 2;
			} else {
				selected_play = column_heights[column] * 2 + column - 2;
			}
		}
		
		if (selected_play != old_selected_play) {
			obj_soul.x = 72 + selected_play % 2 * 264;
			obj_soul.y = 286 + selected_play div 2 * 32;
			audio_play_sound(snd_menu_move, 1, false);
		}
		
		if (global.keys.menu_pressed) {
			info_visible = !info_visible;
			audio_play_sound(snd_menu_move, 1, false);
		}
		
		if (global.keys.confirm_pressed) {
			if ((bp >= global.equipped_plays[selected_play].cost || global.equipped_plays[selected_play].name == "Sucker Punch" && first_turn) && play_availabilities[selected_play]) {
				if (global.equipped_plays[selected_play].type == play_types.support) {
					use_play();
					
					// Return PLAY costs to normal, now that the BP has been removed
					if (global.trinkets.comfort_wraps.equipped) {
						for (var i = 0; i < equipped_plays_length; i++) {
							global.equipped_plays[i].cost += play_discounts[i];
						}
					}
					
					audio_play_sound(snd_support_play, 1, false);
				} else {
					fsm.change("pick_target");
				}
				
				audio_play_sound(snd_select, 1, false);
			} else {
				audio_play_sound(snd_hurt, 1, false);
			}
		} else if (global.keys.cancel_pressed) {
			// Remove Comfort Wraps discounts
			if (global.trinkets.comfort_wraps.equipped) {
				for (var i = 0; i < equipped_plays_length; i++) {
					global.equipped_plays[i].cost += play_discounts[i];
				}
			}
			
			fsm.change("buttons");
		}
	},
	draw: function() {
		draw_set_font(fnt_main);
		for (var i = 0; i < equipped_plays_length; i++) {
			draw_sprite([spr_play_attack, spr_play_support, spr_play_team][global.equipped_plays[i].type], 0, 108 + i % 2 * 256, 287 + i div 2 * 32);
			draw_set_color(((bp >= global.equipped_plays[i].cost || global.equipped_plays[i].name == "Sucker Punch" && first_turn) && play_availabilities[i]) ? c_white : c_gray);
			draw_formatted_text(132 + i % 2 * 256, 271 + i div 2 * 32, format_battle, global.equipped_plays[i].short_name);
		}
		
		draw_set_color(c_white);
		draw_info(get_play_info_text(global.equipped_plays[selected_play]), info_visible);
	}
});

fsm.add("pick_target", {
	enter: function() {
		// Make sure we don't start on a spared/dead enemy
		while (
			global.encounter.enemies[selected_target].state != enemy_states.alive
			&& global.encounter.enemies[selected_target].state != enemy_states.knocked_down
		) {
			selected_target = (selected_target + 1) % enemies_length;
		}
		
		obj_soul.x = 72;
		obj_soul.y = 286 + selected_target * 32;
	},
	step: function() {
		if (enemies_length > 1) {
			var old_selected_target = selected_target;
			
			if (global.keys.down_pressed) {
				do {
					selected_target = (selected_target + 1) % enemies_length;
				} until (
					global.encounter.enemies[selected_target].state == enemy_states.alive
					|| global.encounter.enemies[selected_target].state == enemy_states.knocked_down
				);
			}
			
			if (global.keys.up_pressed) {
				do {
					if (selected_target == 0) {
						selected_target = enemies_length - 1;
					} else {
						selected_target--;
					}
				} until (
					global.encounter.enemies[selected_target].state == enemy_states.alive
					|| global.encounter.enemies[selected_target].state == enemy_states.knocked_down
				);
			}
			
			if (selected_target != old_selected_target) {
				obj_soul.y = 286 + selected_target * 32;
				audio_play_sound(snd_menu_move, 1, false);
			}
		}
		
		if (global.keys.confirm_pressed) {
			if (selected_button == 0) {
				use_play();
				
				// Return PLAY costs to normal, now that the BP has been removed
				// (Yes, this is repeated from above. It's not much code; this is probably fine. At least,
				// I don't want to figure out a "cleaner" way to do it.)
				if (global.trinkets.comfort_wraps.equipped) {
					for (var i = 0; i < equipped_plays_length; i++) {
						global.equipped_plays[i].cost += play_discounts[i];
					}
				}
			} else {
				fsm.change("pick_act");
			}
			
			audio_play_sound(snd_select, 1, false);
		} else if (global.keys.cancel_pressed) {
			fsm.change(selected_button == 0 ? "pick_play": "buttons");
		}
	},
	draw: function() {
		draw_set_font(fnt_main);
		
		var max_name_length = 0;
		for (var i = 0; i < enemies_length; i++) {
			var enemy = global.encounter.enemies[i];
			if (enemy.state == enemy_states.alive || enemy.state == enemy_states.knocked_down) {
				var text = "* " + global.encounter.enemies[i].name;
				if (enemy.state == enemy_states.knocked_down) {
					text = "{c,y}" + text;
				}
				
				draw_formatted_text(100, 271 + i * 32, format_battle, text);
				
				var length = string_length(enemy.name);
				if (length > max_name_length) {
					max_name_length = length;
				}
			}
		}
		
		if (selected_button == 0) {
			var health_bar_x = 190 + max_name_length * 16;
			
			for (var i = 0; i < enemies_length; i++) {
				var enemy = global.encounter.enemies[i];
				
				if (enemy.state == enemy_states.alive || enemy.state == enemy_states.knocked_down) {
					draw_set_color(c_red);
					draw_rectangle(health_bar_x, 280 + i * 32, health_bar_x + 100, 296 + i * 32, false);
					
					if (enemy.current_health > 0) {
						draw_set_color(c_lime);
						draw_rectangle(health_bar_x, 280 + i * 32, health_bar_x + enemy.current_health / enemy.max_health * 100, 296 + i * 32, false);
					}
					
					if (enemy.vulnerable > 0) {
						draw_sprite(spr_vulnerable, 0, health_bar_x + 121, 275 + i * 32);
						draw_set_color(c_white);
						draw_formatted_text(health_bar_x + 152, 280 + i * 32, format_bubble, $"x{enemy.vulnerable}");
					}
				}
			}
			
			draw_set_color(c_white);
		}
	}
});

fsm.add("pick_act", {
	enter: function() {
		selected_act = 0;
		acts_length = array_length(player_turn.acts[selected_target]) + 1;
		
		obj_soul.x = 72;
		obj_soul.y = 286;
	},
	step: function() {
		var column = selected_act % 2;
		var old_selected_act = selected_act;
		
		if (global.keys.right_pressed || global.keys.left_pressed) {
			if (column == 0 && selected_act < acts_length - 1) {
				selected_act++;
			} else if (column == 1) {
				selected_act--;
			}
		}
		
		if (global.keys.down_pressed) {
			if (selected_act < acts_length - 2) {
				selected_act += 2;
			} else {
				selected_act = selected_act % 2;
			}
		}
		
		if (global.keys.up_pressed) {
			if (selected_act > 1) {
				selected_act -= 2;
			} else if (acts_length > selected_act + 2) {
				selected_act = selected_act + 2;
			}
		}
		
		if (selected_act != old_selected_act) {
			obj_soul.x = 72 + selected_act % 2 * 264;
			obj_soul.y = 286 + selected_act div 2 * 32;
			audio_play_sound(snd_menu_move, 1, false);
		}
		
		if (global.keys.confirm_pressed) {
			fsm.change("act_cutscene");
			audio_play_sound(snd_select, 1, false);
		} else if (global.keys.cancel_pressed) {
			fsm.change("pick_target");
		}
	},
	draw: function() {
		draw_set_font(fnt_main);
		draw_formatted_text(100, 271, format_battle, "* Check");
		
		for (var i = 1; i < acts_length; i++) {
			draw_formatted_text(100 + i % 2 * 256, 271 + i div 2 * 32, format_battle, "* " + player_turn.acts[selected_target][i - 1].name);
		}
		
		if (selected_act == 0) {
			draw_rectangle(box.x1, 201, box.x1 + 254, 244, false);
			draw_set_color(c_black);
			draw_rectangle(box.x1 + 5, 206, box.x1 + 249, 239, false);
			draw_set_color(c_white);
			
			draw_formatted_text(box.x1 + 15, 214, format_bubble, "* Does not end your turn.");
		}
	}
});

fsm.add("act_cutscene", {
	enter: function() {
		if (selected_act == 0) {
			var enemy = global.encounter.enemies[selected_target];
			var pages = [string_upper(enemy.name) + " -{a,e} ATK " + string(enemy.attack) + " DEF " + string(enemy.defense) + "\n" + enemy.description[0]];
			
			// I'm not sure if there's a better way to do this, to be honest.
			// array_concat() might've worked if there was a nice way to slice arrays in GameMaker.
			for (var i = 1; i < array_length(enemy.description); i++) {
				array_push(pages, enemy.description[i]);
			}
			
			if (enemy.vulnerable > 0) {
				array_push(pages, "{c,f}Vulnerable{c,w} for " + string(enemy.vulnerable) + " more turns.");
			}
			
			cutscene = cutscene_init()
				.add(new ev_dialogue_battle(pages))
				.start();
			
			if (variable_struct_exists(global.encounter, "check")) {
				check_cutscene = global.encounter.check();
			} else {
				check_cutscene = undefined;
			}
		} else {
			cutscene = player_turn.acts[selected_target][selected_act - 1].cutscene.start();
		}
		
		obj_soul.visible = false;
	},
	end_step: function() {
		if (!instance_exists(cutscene)) {
			if (selected_act == 0) {
				if (!is_undefined(check_cutscene) && instance_exists(check_cutscene)) {
					cutscene = check_cutscene;
					cutscene.start();
				} else {
					// There's no need to set the cursor position, since Check is always in the first slot.
					obj_soul.visible = true;
					fsm.change("pick_act");
				}
			} else {
				array_push(player_actions, {type: player_action_types.act, target: selected_target, act: player_turn.acts[selected_target][selected_act - 1]});
				start_enemy_turn();
			}
		}
	}
});

fsm.add("pick_item", {
	enter: function() {
		pages_length = ceil(array_length(global.inventory) / 4);
		pages = [];
		
		inventory_length = array_length(global.inventory);
		for (var i = 0; i < pages_length; i++) {
			var page = [];
			for (var j = i * 4; j < inventory_length; j++) {
				array_push(page, global.inventory[j]);
			}
			
			array_push(pages, page);
		}
		
		selected_page = 0;
		selected_slot_x = 0;
		selected_slot_y = 0;
		info_visible = false;
		
		obj_soul.x = 72
		obj_soul.y = 286;
	},
	step: function() {
		var old_selected_slot_x = selected_slot_x;
		var old_selected_slot_y = selected_slot_y;
		
		if (global.keys.right_pressed) {
			if (selected_slot_x == 0 && selected_slot_y * 2 + 1 < array_length(pages[selected_page])) {
				selected_slot_x = 1;
			} else {
				selected_slot_x = 0;
				
				var new_page = (selected_page + 1) % pages_length;
				if (selected_slot_y == 0 || array_length(pages[new_page]) >= 3) {
					selected_page = new_page;
				}
			}
		}
		
		if (global.keys.left_pressed) {
			if (selected_slot_x == 0) {
				var new_page;
				if (selected_page == 0) {
					new_page = pages_length - 1;
				} else {
					new_page = selected_page - 1;
				}
				
				var new_page_length = array_length(pages[new_page]);
				if (new_page_length >= (selected_slot_y + 1) * 2 - 1) {
					selected_page = new_page;
					if (new_page_length >= (selected_slot_y + 1) * 2) {
						selected_slot_x = 1;
					}
				} else if (array_length(pages[selected_page]) >= (selected_slot_y + 1) * 2) {
					selected_slot_x = 1;
				}
			} else {
				selected_slot_x = 0;
			}
		}
		
		if (
			(global.keys.down_pressed || global.keys.up_pressed)
			&& (!selected_slot_y * 2 + selected_slot_x < array_length(pages[selected_page]))
		) {
			selected_slot_y = !selected_slot_y;
		}
		
		if (selected_slot_x != old_selected_slot_x || selected_slot_y != old_selected_slot_y) {
			var selected_slot = selected_slot_y * 2 + selected_slot_x;
			obj_soul.x = 72 + selected_slot % 2 * 248;
			obj_soul.y = 286 + selected_slot div 2 * 32;
			
			audio_play_sound(snd_menu_move, 1, false);
		}
		
		if (global.keys.menu_pressed) {
			info_visible = !info_visible;
			audio_play_sound(snd_menu_move, 1, false);
		}
		
		if (global.keys.confirm_pressed) {
			var index = selected_page * 4 + selected_slot_y * 2 + selected_slot_x;
			selected_item = global.inventory[index];
			use_text = use_item(index);
			fsm.change("item_dialogue");
			
			audio_play_sound(snd_select, 1, false);
		} else if (global.keys.cancel_pressed) {
			fsm.change("buttons");
		}
	},
	draw: function() {
		draw_set_font(fnt_main);
		
		var page_start = selected_page * 4;
		for (var i = 0; i < 4 && page_start + i < inventory_length; i++) {
			draw_formatted_text(100 + i % 2 * 240, 271 + i div 2 * 32, format_battle, "* " + global.inventory[page_start + i].short_name);
		}
		
		draw_formatted_text(388, 335, format_battle, "PAGE " + string(selected_page + 1));
		
		draw_info(global.inventory[selected_page * 4 + selected_slot_y * 2 + selected_slot_x].battle_info, info_visible);
	}
});

fsm.add("item_dialogue", {
	enter: function() {
		cutscene = cutscene_init().add(new ev_dialogue_battle(use_text)).start();
		obj_soul.visible = false;
	},
	end_step: function() {
		if (!instance_exists(cutscene)) {
			array_push(player_actions, {type: player_action_types.item, item: selected_item});
			start_enemy_turn();
		}
	}
});

fsm.add("mercy", {
	enter: function() {
		selected_option = 0;
		
		any_sparable = false;
		for (var i = 0; i < enemies_length; i++) {
			if (global.encounter.enemies[i].state == enemy_states.knocked_down) {
				any_sparable = true;
				break;
			}
		}
		
		fleeing = false;
		flee_x = 80;
		
		// Since the fleeing SOUL isn't an object, we have to animate it manually.
		flee_animation_timer = 0;
		
		obj_soul.x = 72;
		obj_soul.y = 286 + selected_option * 32;
	},
	step: function() {
		if (fleeing) {
			flee_x -= 3;
			flee_animation_timer = (flee_animation_timer + 1) % 4;
			
			if (flee_x == -22) {
				instance_create_layer(0, 0, "system", obj_fade, {type: fade_types.out, frames: 13});
			} else if (flee_x == -58) {
				audio_stop_all();
				room_goto(global.battle_return_room);
			}
			
			return;
		}
		
		if (player_turn.can_flee && (global.keys.up_pressed || global.keys.down_pressed)) {
			selected_option = !selected_option;
			obj_soul.y = 286 + selected_option * 32;
			audio_play_sound(snd_menu_move, 1, false);
		}
		
		if (global.keys.confirm_pressed) {
			if (selected_option) {
				if (random(10) <= flee_chance) {
					fleeing = true;
					flee_text = choose(
						"* I'm outta here.",
						"* I've got better to do.",
						"* Escaped...",
						"* Don't slow me down."
					);
					
					obj_soul.visible = false;
					audio_play_sound(snd_flee, 1, false);
				} else {
					array_push(player_actions, {type: player_action_types.flee_fail});
					start_enemy_turn();
					audio_play_sound(snd_select, 1, false);
				}
			} else {
				var spared = [];
				var fight_won = true;
				
				for (var i = 0; i < enemies_length; i++) {
					with (global.encounter.enemies[i]) {
						if (state == enemy_states.knocked_down && spareable) {
							state = enemy_states.spared;
							array_push(spared, self);
							other.earned_gold += gold;
							
							with (instance) {
								repeat (14) {
									var dir = random(360);
									var cloud = instance_create_layer(
										x + lengthdir_x(random(16), dir),
										center_y + lengthdir_y(random(16), dir),
										"vapor",
										obj_spare_cloud,
										{direction: dir}
									);
								}
							}
						}
						
						if (state != enemy_states.spared && state != enemy_states.dead) {
							fight_won = false;
						}
					}
				}
				
				if (fight_won) {
					fsm.change("win");
				} else {
					array_push(player_actions, {type: player_action_types.spare, spared: spared});
					start_enemy_turn();
				}
				
				if (array_length(spared) > 0) {
					audio_play_sound(snd_vaporized, 1, false);
				} else {
					audio_play_sound(snd_select, 1, false);
				}
			}
		} else if (global.keys.cancel_pressed) {
			fsm.change("buttons");
		}
	},
	draw: function() {
		if (fleeing) {
			draw_formatted_text(52, 271, format_battle, flee_text);
			draw_sprite(spr_soul_flee, flee_animation_timer > 1, flee_x, 326);
		} else {
			draw_formatted_text(100, 271, format_battle, any_sparable ? "{c,y}* Spare" : "* Spare");
			if (player_turn.can_flee) {
				draw_formatted_text(100, 303, format_battle, "* Flee");
			}
		}
	}
});

fsm.add("transform_box", {
	enter: function() {
		box_start = {x1: box.x1, y1: box.y1, x2: box.x2, y2: box.y2};
		
		// In case we instantly change to the next state, we need to make the SOUL invisible in advance.
		obj_soul.visible = false;
		
		// Skip transformations if they're not needed
		if (box.x1 == new_box.x1 && box.y1 == new_box.y1 && box.x1 == new_box.x1 && box.y1 == new_box.y1) {
			fsm.change(next_state);
			return;
		} else if (
			transform_reverse && box.y1 == new_box.y1 && box.y2 == new_box.y2
			|| !transform_reverse && box.x1 == new_box.x1 && box.x2 == new_box.x2
		) {
			progress = 1;
		} else {
			progress = 0;
		}
	},
	step: function() {
		progress += 0.1;
		if (progress <= 1) {
			if (transform_reverse) {
				box.y1 = lerp(box_start.y1, new_box.y1, progress);
				box.y2 = lerp(box_start.y2, new_box.y2, progress);
			} else {
				box.x1 = lerp(box_start.x1, new_box.x1, progress);
				box.x2 = lerp(box_start.x2, new_box.x2, progress);
			}
		} else {
			var real_progress = progress - 1;
			if (transform_reverse) {
				box.x1 = lerp(box_start.x1, new_box.x1, real_progress);
				box.x2 = lerp(box_start.x2, new_box.x2, real_progress);
			} else {
				box.y1 = lerp(box_start.y1, new_box.y1, real_progress);
				box.y2 = lerp(box_start.y2, new_box.y2, real_progress);
			}
		}
		
		if (fsm.get_previous_state() == "attack" && enemy_turn.attack.overlay && overlay_alpha > 0) {
			overlay_alpha -= 0.1;
		}
		
		// Finish early if the second transformation isn't needed
		if (progress == 2 || progress == 1 && (
			transform_reverse && box.x1 == new_box.x1 && box.x2 == new_box.x2
			|| !transform_reverse && box.y1 == new_box.y1 && box.y2 == new_box.y2
		)) {
			fsm.change(next_state);
		}
	}
});

fsm.add("minigame_combo", {
	enter: function() {
		play_name = global.equipped_plays[selected_play].name;
		
		combo = [];
		combo_length = (play_name == "Strike" ? 5 : 7);
		
		if (play_name == "Strike") {
			repeat (combo_length) {
				array_push(combo, choose(directions.right, directions.up, directions.left, directions.down));
			}
		} else {
			array_push(combo, choose(directions.right, directions.up, directions.left, directions.down));
			
			var dir = choose(-1, 1);
			for (var i = 0; i < combo_length - 1; i++) {
				if (dir == -1) {
					switch (combo[i]) {
						case directions.right: array_push(combo, directions.up); break;
						case directions.up: array_push(combo, directions.left); break;
						case directions.left: array_push(combo, directions.down); break;
						case directions.down: array_push(combo, directions.right); break;
					}
				} else {
					switch (combo[i]) {
						case directions.right: array_push(combo, directions.down); break;
						case directions.down: array_push(combo, directions.left); break;
						case directions.left: array_push(combo, directions.up); break;
						case directions.up: array_push(combo, directions.right); break;
					}
				}
			}
		}
		
		combo_progress = 0;
		input_timer = 15;
		
		critical = true;
		criticals = [];
		
		minigame_end = false;
		animating = false;
	},
	step: function() {
		input_timer--;
		
		if (minigame_end) {
			if (animating) {
				play_animation();
			} else if (!instance_exists(obj_damage_bar) && !instance_exists(obj_miss)) {
				array_push(player_actions, {type: player_action_types.play, target: selected_target, play: global.equipped_plays[selected_play], miss: miss});
				
				if (critical && !miss && play_name == "Roundhouse Kick") {
					start_player_turn();
				} else {
					start_enemy_turn();
				}
			}
			
			return;
		}
		
		if (input_timer / 15 <= -0.5) {
			miss = true;
			minigame_end = true;
		} else {
			var correct_input;
			switch (combo[combo_progress]) {
				case directions.right: correct_input = global.keys.right_pressed; break;
				case directions.up: correct_input = global.keys.up_pressed; break;
				case directions.left: correct_input = global.keys.left_pressed; break;
				case directions.down: correct_input = global.keys.down_pressed; break;
			}
			
			if (correct_input) {
				audio_play_sound(snd_combo_hit, 1, false, 1, 0, power(2, combo_progress / 12));
				
				// To get a critical hit, all inputs must be hit within a 5 frame window
				if (abs(input_timer) > 2) {
					critical = false;
					array_push(criticals, false);
				} else {
					array_push(criticals, true);
					
					var middle_x = box.x1 + 36 + combo_progress * 48;
					var middle_y = 328;  // The code below is easier to read if we define this constant
					
					repeat (irandom_range(6, 8)) {
						var sparkle_x;
						var sparkle_y;
						
						if (choose(1, 2) == 1) {
							sparkle_x = irandom_range(middle_x - 23, middle_x + 22);
							sparkle_y = choose(middle_y - 23, middle_y + 22);
						} else {
							sparkle_x = choose(middle_x - 23, middle_x + 22);
							sparkle_y = irandom_range(middle_y - 23, middle_y + 22);
						}
						
						instance_create_layer(sparkle_x, sparkle_y, "top", obj_combo_sparkle, {move_direction: point_direction(middle_x, middle_y, sparkle_x, sparkle_y)});
					}
				}
				
				if (++combo_progress == combo_length) {
					miss = false;
					minigame_end = true;
				}
				
				input_timer = 15;
			} else if (global.keys.right_pressed || global.keys.up_pressed || global.keys.left_pressed || global.keys.down_pressed) {
				miss = true;
				minigame_end = true;
			}
		}
		
		if (minigame_end) {
			enemy = global.encounter.enemies[selected_target];
			if (miss) {
				instance_create_layer(enemy.instance.x, enemy.instance.damage_bar_y, "bullets", obj_miss);
				audio_play_sound(snd_combo_miss, 1, false);
			} else {
				damage = floor((get_player_attack() * ((play_name == "Roundhouse Kick" || critical) ? 1 : 0.5)) - enemy.defense + 20);
				if (damage > 0) {
					animating = true;
					animation_sprite = (play_name == "Roundhouse Kick" ? spr_kick : spr_strike_hit);
					animation_image = 0;
					audio_play_sound(snd_strike_hit, 1, false);
				} else {
					instance_create_layer(enemy.instance.x, enemy.instance.damage_bar_y, "bullets", obj_miss);
					audio_play_sound(snd_combo_miss, 1, false);
				}
			}
		}
	},
	draw: function() {
		var pulse_modifier = (combo_progress > 0 ? 0.3 * dsin(min((15 - input_timer) / 7, 1) * 180) : 0);
		for (var i = 0; i <= combo_progress && i < combo_length; i++) {
			if (i == combo_progress - 1) {
				draw_sprite_ext(spr_combo_arrow, 0, box.x1 + 36 + i * 48, 328, 1 - pulse_modifier, 1 - pulse_modifier, combo[i] * 90, i == combo_progress ? c_gray : (criticals[i] ? c_orange : c_white), 1);
			} else {
				draw_sprite_ext(spr_combo_arrow, 0, box.x1 + 36 + i * 48, 328, 1, 1, combo[i] * 90, i == combo_progress ? c_gray : (criticals[i] ? c_orange : c_white), 1);
			}
			
			if (!minigame_end) {
				draw_set_color(c_orange);
				var offset = input_timer / 15 * 32;
				draw_rectangle(box.x1 + 20 + combo_progress * 48 - offset, 312 - offset, box.x1 + 51 + combo_progress * 48 + offset, 343 + offset, true);
				draw_rectangle(box.x1 + 21 + combo_progress * 48 - offset, 313 - offset, box.x1 + 50 + combo_progress * 48 + offset, 342 + offset, true);
			}
		}
		
		draw_set_color(c_white);
		
		if (animating && !is_undefined(animation_sprite)) {
			draw_sprite_ext(animation_sprite, animation_image, enemy.instance.x, enemy.instance.center_y, 2, 2, 0, critical ? c_orange: c_white, 1);
		}
	}
});

fsm.add("minigame_reaction", {
	enter: function() {
		alert_timer = irandom_range(40, 90);
		
		alert_color = c_red;
		alert_alpha = 1;
		alert_fading = false;
		
		animating = false;
	},
	step: function() {
		if (alert_fading) {
			if (alert_alpha > 0) {
				alert_alpha -= 0.05;
				if (alert_alpha < 0) {
					alert_alpha = 0;
				}
			}
			
			if (animating) {
				play_animation();
			} else if (!instance_exists(obj_damage_bar) && !instance_exists(obj_miss)) {
				start_player_turn();
			}
			
			return;
		}
		
		if (--alert_timer < 0) {
			if (alert_timer == -1) {
				audio_play_sound(snd_encounter, 1, false);
			}
			
			if (global.keys.confirm_pressed) {
				alert_color = c_lime;
				alert_fading = true;
				
				enemy = global.encounter.enemies[selected_target];
				damage = floor(get_player_attack() * 2 - enemy.defense + 20);
				
				miss = false;
				
				animating = true;
				animation_sprite = spr_strike_hit;
				animation_image = 0;
				audio_play_sound(snd_strike_hit, 1, false);
			}
		}
		
		if (alert_timer < -20 || alert_timer >= 0 && global.keys.confirm_pressed) {
			alert_fading = true;
			
			enemy = global.encounter.enemies[selected_target];
			instance_create_layer(enemy.instance.x, enemy.instance.damage_bar_y, "bullets", obj_miss);
			
			miss = true;
		}
	},
	draw: function() {
		if (alert_timer < 0) {
			draw_sprite_ext(spr_reaction_alert, min((-alert_timer + 1) div 2, 3), 320, 320, 1, 1, 0, alert_color, alert_alpha);
		}
		
		draw_set_alpha(0.25);
		draw_sprite(spr_reaction_reticle, 0, 320, 320);
		draw_set_alpha(1);
		
		if (animating && !is_undefined(animation_sprite)) {
			draw_sprite_ext(animation_sprite, animation_image, enemy.instance.x, enemy.instance.center_y, 2, 2, 0, c_white, 1);
		}
		
		if (alert_timer < 0) {
			draw_minigame_timer(20 + alert_timer, 20);
		}
	}
});

fsm.add("minigame_mash", {
	enter: function() {
		mash_progress = 0;
		remaining_time = 120;
		z_timer = 0;
		
		bar_surface = undefined;
		
		minigame_end = false;
		animating = false;
	},
	leave: function() {
		if (!is_undefined(bar_surface)) {
			surface_free(bar_surface);
		}
	},
	step: function() {
		if (minigame_end) {
			if (animating) {
				play_animation();
			} else if (!instance_exists(obj_damage_bar) && !instance_exists(obj_miss)) {
				array_push(player_actions, {type: player_action_types.play, target: selected_target, play: global.equipped_plays[selected_play], miss: miss});
				start_enemy_turn();
			}
			
			return;
		}
		
		if (global.keys.confirm_pressed) {
			audio_play_sound(snd_graze, 1, false);
			
			mash_progress += 0.085;
			if (mash_progress >= 1) {
				mash_progress = 1;
				
				enemy = global.encounter.enemies[selected_target];
				damage = floor(get_player_attack() * (1.5 + (global.stats.max_health - global.stats.current_health) div 20 * 0.25) - enemy.defense + 20);
				
				miss = false;
				minigame_end = true;
				
				animating = true;
				animation_sprite = spr_strike_hit;
				animation_image = 0;
				audio_play_sound(snd_strike_hit, 1, false);
				
				return;
			}
		} else {
			mash_progress -= 0.01;
			if (mash_progress < 0) {
				mash_progress = 0;
			}
		}
		
		if (remaining_time-- == 0) {
			enemy = global.encounter.enemies[selected_target];
			instance_create_layer(enemy.instance.x, enemy.instance.damage_bar_y, "bullets", obj_miss);
			
			miss = true;
			minigame_end = true;
		}
		
		// Blinking Z animation
		if (++z_timer == 30) {
			z_timer = 0;
		}
	},
	draw: function() {
		draw_sprite(spr_mash_bar, 0, 320, 320);
		
		if (z_timer < 15) {
			draw_set_font(fnt_main);
			draw_text(314, 305, "Z");
		} else {
			draw_sprite_ext(spr_mash_z_outline, 0, 320, 320, 2, 2, 0, c_white, 1);
		}
		
		if (mash_progress > 0) {
			if (!surface_exists(bar_surface)) {
				bar_surface = surface_create(89, 108);
			}
			
			surface_set_target(bar_surface);
			draw_clear_alpha(c_black, 0);
			draw_rectangle(0, (1 - mash_progress) * 107, 89, 107, false);
			gpu_set_blendmode(bm_subtract);
			draw_sprite(spr_mash_bar_mask, 0, 0, 0);
			gpu_set_blendmode(bm_normal);
			surface_reset_target();
			
			draw_surface(bar_surface, 276, 266);
		}
		
		if (animating && !is_undefined(animation_sprite)) {
			draw_sprite_ext(animation_sprite, animation_image, enemy.instance.x, enemy.instance.center_y, 2, 2, 0, c_white, 1);
		}
		
		draw_minigame_timer(remaining_time, 120);
	}
});

fsm.add("minigame_alternate", {
	enter: function() {
		current_input = "Z";
		progress = 0;
		remaining_time = 45;
		
		minigame_end = false;
		animating = false;
	},
	step: function() {
		if (minigame_end) {
			if (animating) {
				play_animation();
			} else if (!instance_exists(obj_damage_bar) && !instance_exists(obj_miss)) {
				if (!miss) {
					enemy.pending_vulnerable += 3;
				}
				
				array_push(player_actions, {type: player_action_types.play, target: selected_target, play: global.equipped_plays[selected_play], miss: miss});
				start_enemy_turn();
			}
		} else if (global.keys.confirm_pressed && current_input == "Z" ||  global.keys.cancel_pressed && current_input == "X") {
			if (current_input == "Z") {
				current_input = "X";
			} else {
				current_input = "Z";
			}
			
			if (++progress == 8) {
				enemy = global.encounter.enemies[selected_target];
				damage = get_player_attack() - enemy.defense + 20;
				
				miss = false;
				minigame_end = true;
				
				animating = true;
				animation_sprite = spr_bash;
				animation_image = 0;
				audio_play_sound(snd_strike_hit, 1, false);
			}
			
			audio_play_sound(snd_flicker, 1, false);
		} else if (global.keys.confirm_pressed || global.keys.cancel_pressed || --remaining_time == 0) {
			enemy = global.encounter.enemies[selected_target];
			instance_create_layer(enemy.instance.x, enemy.instance.damage_bar_y, "bullets", obj_miss);
			
			miss = true;
			minigame_end = true;
		}
	},
	draw: function() {
		draw_set_font(fnt_main);
		
		var z_down = (current_input == "X" || minigame_end);
		draw_rectangle(278, z_down ? 305 : 302, 307, z_down ? 334 : 331, true);
		draw_rectangle(278, z_down ? 336 : 333, 307, 337, true);
		draw_text(287, z_down ? 304 : 301, "Z");
		
		var x_down = (current_input == "Z" || minigame_end);
		draw_rectangle(332, x_down ? 305 : 302, 361, x_down ? 334 : 331, true);
		draw_rectangle(332, x_down ? 336 : 333, 361, 337, true);
		draw_text(341, x_down ? 304 : 301, "X");
		
		if (animating && !is_undefined(animation_sprite)) {
			draw_sprite_ext(animation_sprite, animation_image, enemy.instance.x, enemy.instance.center_y, 2, 2, 0, c_white, 1);
		}
		
		draw_minigame_timer(remaining_time, 45);
	}
});

fsm.add("minigame_trip", {
	enter: function() {
		input_direction = choose(-1, 1);
		progress = 0;
		animation_progress = [0, 0, 0];
		remaining_time = 45;
		
		minigame_end = false;
		animating = false;
	},
	step: function() {
		if (minigame_end) {
			if (animating) {
				play_animation();
			} else if (!instance_exists(obj_damage_bar) && !instance_exists(obj_miss)) {
				if (!miss) {
					enemy.pending_vulnerable++;
				}
				
				start_player_turn();
			}
		} else {
			var success = undefined;
			switch (progress) {
				case 0:
					if (global.keys.confirm_pressed && input_direction == 1 || global.keys.menu_pressed && input_direction == -1) {
						success = true;
					} else if (global.keys.confirm_pressed || global.keys.cancel_pressed || global.keys.menu_pressed) {
						success = false;
					}
					
					break;
				
				case 1:
					if (global.keys.cancel_pressed) {
						success = true;
					} else if (global.keys.confirm_pressed || global.keys.menu_pressed) {
						success = false;
					}
					
					break;
				
				case 2:
					if (global.keys.menu_pressed && input_direction == 1 || global.keys.confirm_pressed && input_direction == -1) {
						success = true;
					} else if (global.keys.confirm_pressed || global.keys.cancel_pressed || global.keys.menu_pressed) {
						success = false;
					}
					
					break;
			}
			
			if (success) {
				if (++progress == 3) {
					enemy = global.encounter.enemies[selected_target];
					damage = floor(get_player_attack() * 0.5 - enemy.defense + 20);
					
					miss = false;
					minigame_end = true;
					
					animating = true;
					animation_sprite = spr_trip;
					animation_image = 0;
					audio_play_sound(snd_strike_hit, 1, false);
				}
				
				audio_play_sound(snd_flicker, 1, false);
			} else if (success == false || --remaining_time == 0) {  // undefined doesn't count
				enemy = global.encounter.enemies[selected_target];
				instance_create_layer(enemy.instance.x, enemy.instance.damage_bar_y, "bullets", obj_miss);
				
				miss = true;
				minigame_end = true;
			}
		}
		
		if (input_direction == 1) {
			for (var i = 0; i < progress; i++) {
				if (animation_progress[i] < 1) {
					animation_progress[i] += 0.125;
				}
			}
		} else {
			for (var i = 2; i > 2 - progress; i--) {
				if (animation_progress[i] < 1) {
					animation_progress[i] += 0.125;
				}
			}
		}
	},
	draw: function() {
		draw_sprite(spr_trip_riley, progress, 319, 332);
		
		draw_set_font(fnt_main);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		
		for (var i = 0; i < 3; i++) {
			var real_progress = (input_direction == 1 ? progress : 2 - progress);
			if (real_progress == i && !minigame_end) {
				draw_set_color(c_white);
			} else if (animation_progress[i] > 0) {
				draw_set_color(merge_color(c_white, c_lime, animation_progress[i]));
			} else {
				draw_set_color(c_gray);
			}
			
			var scale = 1 - dsin(animation_progress[i] * 180) * 0.25;
			draw_text_transformed(293 + i * 28, 358, ["Z", "X", "C"][i], scale, scale, 0);
		}
		
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_color(c_white);
		
		if (animating && !is_undefined(animation_sprite)) {
			draw_sprite_ext(animation_sprite, animation_image, enemy.instance.x, enemy.instance.center_y, 2, 2, 0, c_white, 1);
		}
		
		draw_minigame_timer(remaining_time, 45);
	}
});

fsm.add("enemy_cutscene", {
	enter: function() {
		if (!is_undefined(enemy_turn.attack) && enemy_attacks_enabled) {
			obj_soul.x = (box.x1 + box.x2) div 2;
			obj_soul.y = (box.y1 + box.y2) div 2;
			obj_soul.visible = true;
		}
		
		if (is_undefined(enemy_turn.cutscene)) {
			fsm.change("attack");
		} else {
			enemy_turn.cutscene.start();
		}
	},
	end_step: function() {
		if (!instance_exists(enemy_turn.cutscene)) {
			if (enemy_turn.win_type == win_types.after_cutscene) {
				fsm.change("win");
			} else if (is_undefined(enemy_turn.attack) || !enemy_attacks_enabled) {	
				end_enemy_turn();
				start_player_turn(false);
			} else {
				fsm.change("attack");
			}
		}
	}
});

fsm.add("attack", {
	enter: function() {
		pattern = instance_create_layer(0, 0, "system", enemy_turn.attack.pattern);
		times_hurt = 0;  // Used for trinkets
		
		// Times hit by each enemy (currently only used for Magic Mirror)
		times_hit_per_enemy = []
		repeat (enemies_length) {
			array_push(times_hit_per_enemy, 0);
		}
		
		if (deep_breath) {
			bp_heals = call_later(1, time_source_units_seconds, function() {
				bp += 5;
				if (bp > 100) {
					bp = 100;
				}
			}, true);
		}
		
		if (endure) {
			obj_soul.grace_turns = 1;
		} else {
			obj_soul.grace_turns = 0;
		}
	},
	leave: function() {
		// These may end up as fractional values in some cases, which could add unnecessary decimals to
		// item use text. We can't round them during the enemy's attack, or the very small increases that
		// cause these fractional values would just round away to nothing, so instead, we round them here.
		//
		// Health is rounded up, since it should never show as 0.
		// BP is rounded down, on the other hand, so that the amount shown on-screen is never exaggerated.
		global.stats.current_health = ceil(global.stats.current_health);
		bp = floor(bp);
	},
	end_step: function() {
		if (instance_exists(pattern)) {
			if (enemy_turn.attack.overlay && overlay_alpha < 0.5) {
				overlay_alpha += 0.05;
			}
		} else {
			if (deep_breath) {
				call_cancel(bp_heals);
			}
			
			end_enemy_turn();
			
			if (global.trinkets.magic_cherry.equipped && times_hurt == 0) {
				global.stats.current_health = min(global.stats.current_health + floor(global.stats.max_health * 0.1), global.stats.max_health);
				trinket_pulse(global.trinkets.magic_cherry);
				audio_play_sound(snd_power, 1, false);
			}
			
			var reflect_boosts_length = array_length(reflect_boosts);
			if (global.trinkets.magic_mirror.equipped || reflect_boosts_length > 0) {
				var damage_dealt = false;
				for (var i = 0; i < enemies_length; i++) {
					var enemy = global.encounter.enemies[i];
					if (times_hit_per_enemy[i] > 0 && enemy.state == enemy_states.alive) {
						var boost = 0;
						for (var j = 0; j < reflect_boosts_length; j++) {
							if (reflect_boosts[j].enemy == i) {
								boost += reflect_boosts[j].damage;
							}
						}
						
						var damage = (global.trinkets.magic_mirror.equipped ? floor(get_player_attack() * times_hit_per_enemy[i]) : 0) + boost;
						if (damage > 0) {
							instance_create_layer(enemy.instance.x, enemy.instance.damage_bar_y, "bullets", obj_damage_bar, {enemy: enemy, damage: damage});
							damage_dealt = true;
						}
					}
				}
				
				if (damage_dealt) {
					trinket_pulse(global.trinkets.magic_mirror);
					
					new_box = dialogue_box;
					transform_reverse = true;
					next_state = "magic_mirror";
					fsm.change("transform_box");
				} else {
					start_player_turn(false);
				}
			} else {
				start_player_turn(false);
			}
		}
	}
});

fsm.add("magic_mirror", {
	step: function() {
		if (!instance_exists(obj_damage_bar)) {
			start_player_turn();
		}
	}
});

fsm.add("win", {
	enter: function() {
		global.stats.execution_points += earned_exp;
		global.stats.gold += earned_gold;
		
		// We have to do this before the LOVE increase sound potentially plays.
		if (variable_struct_exists(global.encounter, "music")) {  // A "music" variable is the correct way to handle music in encounters.
			audio_stop_sound(global.encounter.music);
		}
		
		var text = $"YOU WON!\nYou earned {earned_exp} XP and {earned_gold} gold.";
		
		var love_increase = false;
		while (global.stats.execution_points >= global.required_exp[global.stats.love]) {
			global.stats.love++;
			
			// Max HP should stay at 1 during One Hit Wonder.
			if (global.challenge != challenges.one_hit_wonder) {
				global.stats.max_health += (global.stats.love == 20 ? 20 : 10);
			}
			
			global.stats.attack += (global.stats.love == 20 ? 4 : 2);
			
			if (global.stats.love % 2 == 0) {
				global.stats.defense++;
			}
			
			love_increase = true;
		}
		
		if (love_increase) {
			text += "\nYour LOVE increased.";
			audio_play_sound(snd_love, 1, false);
		}
		
		win_typewriter = new typewriter(format_battle, 32, true, snd_blip_generic, false, noone, text);
		fading = false;
		
		obj_soul.visible = false;
	},
	step: function() {
		win_typewriter.step();
		
		if (fading) {
			if (!instance_exists(obj_fade)) {
				audio_stop_all();
				room_goto(global.battle_return_room);
			}
		} else if (global.keys.confirm_pressed && win_typewriter.shown_chars == win_typewriter.text_length) {
			instance_create_layer(0, 0, "system", obj_fade, {type: fade_types.out, frames: 13});
			fading = true;
		}
	},
	draw: function() {
		win_typewriter.draw(52, 271);
	}
});