var soul_x;
var soul_y;

if (soul_moving) {
	var animation_progress = 1 - power(1 - soul_move_progress, 3);
	soul_x = global.death_x + soul_distance_x * animation_progress;
	soul_y = global.death_y + soul_distance_y * animation_progress;
	bright_soul_alpha = 1 - animation_progress;
} else if (soul_move_progress == 0) {
	soul_x = global.death_x;
	soul_y = global.death_y;
} else {
	soul_x = 320;
	soul_y = 270;
}

if (music_building_up || refusing && refuse_timer < 40) {
	soul_x += random(3) - random(3);
	soul_y += random(3) - random(3);
}

draw_sprite(soul_sprite, 1, soul_x, soul_y);
draw_set_alpha(bright_soul_alpha);
draw_sprite(soul_sprite, 0, soul_x, soul_y);
draw_set_alpha(1);

draw_sprite_ext(spr_game_over, 0, 320, 33, 1, 1, 0, c_white, game_over_alpha);

if (dialogue_running) {
	dialogue_typewriter.draw(122, 321);
}

if (ui_alpha > 0) {
	draw_set_alpha(ui_alpha);
	draw_set_color(selection == 0 ? c_yellow : c_white);
	draw_set_halign(fa_right);
	draw_text(240, 357, "Continue");
	draw_set_halign(fa_left);
	draw_set_color(global.combat_demo_flags.completed_tutorial ? (selection == 1 ? c_yellow : c_white) : c_gray);
	draw_text(399, 357, "Main Menu");
	draw_set_color(c_white);
}

draw_set_alpha(overlay_alpha);
draw_set_color(c_black);
draw_rectangle(0, 0, 639, 479, false);
draw_set_color(c_white);
draw_set_alpha(1);