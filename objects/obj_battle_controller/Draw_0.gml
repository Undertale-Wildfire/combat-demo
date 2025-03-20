if (!surface_exists(ui_surface)) {
	ui_surface = surface_create(640, 480);
}

surface_set_target(ui_surface);
draw_clear_alpha(c_black, 0);

// Draw name + LOVE
draw_set_font(fnt_battle_stats);
draw_text(30, 401, "RILEY  LV " + string(global.stats.love));

// Draw buttons
for (var i = 0; i < 4; i++) {
	if (i == selected_button && !array_contains([
		"transform_box",
		"minigame_combo",
		"minigame_reaction",
		"minigame_mash",
		"minigame_alternate",
		"minigame_trip",
		"act_cutscene",
		"enemy_cutscene",
		"attack",
		"magic_mirror",
		"win"
	], fsm.get_current_state())) {
		draw_sprite(button_sprites[i], (i == 2 && array_length(global.inventory) == 0 ? 3 : 1), button_positions[i], 432);
	} else {
		draw_sprite(button_sprites[i], (i == 2 && array_length(global.inventory) == 0 ? 2 : 0), button_positions[i], 432);
	}
}

// Draw trinket icons
for (var i = 0; i < equipped_trinkets_length; i++) {
	if (equipped_trinkets_animations[i].animating) {
		equipped_trinkets_animations[i].progress += 0.0625;
		if (equipped_trinkets_animations[i].progress >= 1) {
			equipped_trinkets_animations[i].progress = 1;
			equipped_trinkets_animations[i].animating = false;
		}
		
		var position = dsin(equipped_trinkets_animations[i].progress * 180);
		var scale = 1 + position / 5;
		
		draw_sprite_ext(spr_trinket_icons, equipped_trinkets[i].icon, 21 + i * 37, 21, scale, scale, 0, c_gray, 1);
		draw_sprite_ext(spr_trinket_icons, equipped_trinkets[i].icon, 21 + i * 37, 21, scale, scale, 0, c_white, position);
	} else {
		draw_sprite_ext(spr_trinket_icons, equipped_trinkets[i].icon, 21 + i * 37, 21, 1, 1, 0, c_gray, 1);
	}
}

// Draw attack overlay
if (overlay_alpha > 0) {
	draw_set_alpha(overlay_alpha);
	draw_set_color(c_black);
	draw_rectangle(0, 0, 639, 479, false);
	draw_set_color(c_white);
	draw_set_alpha(1);
}

// Draw box
draw_rectangle(box.x1, box.y1, box.x2, box.y2, false);
draw_set_color(c_black);
draw_rectangle(box.x1 + 5, box.y1 + 5, box.x2 - 5, box.y2 - 5, false);
draw_set_color(c_white);

// Get item for health/BP meters
var item;
if (fsm.get_current_state() == "pick_item") {
	item = global.inventory[selected_page * 4 + selected_slot_y * 2 + selected_slot_x];
} else {
	item = undefined;
}

// Draw health meter
draw_sprite(spr_label_health, 0, 189, 405);
draw_set_color(c_red);
draw_rectangle(219, 400, 219 + global.stats.max_health * 1.2, 420, false);

if (!is_undefined(item) && variable_struct_exists(item, "heal_hp")) {
	draw_set_color(c_orange);
	draw_rectangle(219, 400, 219 + min(global.stats.current_health + item.heal_hp, global.stats.max_health) * 1.2, 420, false);
}

draw_set_color(c_yellow);
draw_rectangle(219, 400, 219 + global.stats.current_health * 1.2, 420, false);
draw_set_color(c_white);
draw_text(234 + global.stats.max_health * 1.2, 401, $"{ceil(global.stats.current_health)} / {global.stats.max_health}");

// Draw BP meter
var bp_meter_x = 473;
draw_sprite(spr_label_bp, 0, bp_meter_x, 405);
draw_set_color(c_gray);
draw_rectangle(bp_meter_x + 30, 400, bp_meter_x + 79, 420, false);

if (!is_undefined(item) && variable_struct_exists(item, "heal_bp")) {
	draw_set_color(c_yellow);
	draw_rectangle(bp_meter_x + 30, 400, bp_meter_x + min(visible_bp + item.heal_bp, 100) / 2 + 29, 420, false);
}

draw_set_color(visible_bp == 100 ? c_yellow : c_orange);
draw_rectangle(bp_meter_x + 30, 400, bp_meter_x + visible_bp / 2 + 29, 420, false);
draw_set_color(c_white);

if (visible_bp == 100) {
	draw_sprite(spr_label_max, 0, bp_meter_x + 94, 405);
} else {
	draw_text(bp_meter_x + 94, 401, string(floor(visible_bp)) + "%");
}

// State-specific drawing
fsm.draw();

surface_reset_target();
draw_surface_ext(ui_surface, 0, 0, 1, 1, 0, c_white, ui_alpha);