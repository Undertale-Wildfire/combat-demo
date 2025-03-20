draw_rectangle(32, info_box_y, 173, info_box_y + 109, false);
draw_rectangle(32, 168, 173, 315, false);
draw_set_color(c_black);
draw_rectangle(38, info_box_y + 6, 167, info_box_y + 103, false);
draw_rectangle(38, 174, 167, 309, false);
draw_set_color(c_white);

draw_set_font(fnt_small);
draw_text(46, info_box_y + 42, "LV");
draw_text(82, info_box_y + 42, string(global.stats.love));
draw_text(46, info_box_y + 60, "HP");
draw_text(82, info_box_y + 60, $"{global.stats.current_health}/{global.stats.max_health}");
draw_text(46, info_box_y + 78, "G");
draw_text(82, info_box_y + 78, string(global.stats.gold));

draw_set_font(fnt_main);
draw_text(46, info_box_y + 9, "Riley");

var inventory_empty = (array_length(global.inventory) == 0);

if (global.challenge == challenges.trinketless && submenu_scroll == 1 || global.challenge == challenges.patience) {
	draw_set_color(c_gray);
}

draw_text(84, 189, submenus[submenu_scroll]);

if (inventory_empty && submenu_scroll == 1 || global.challenge == challenges.trinketless && submenu_scroll == 0) {
	draw_set_color(c_gray);
} else if (global.challenge != challenges.patience || submenu_scroll > 0) {
	draw_set_color(c_white);
}

draw_text(84, 225, submenus[submenu_scroll + 1]);

if (inventory_empty && submenu_scroll == 0) {
	draw_set_color(c_gray);
} else if (
	inventory_empty && submenu_scroll == 1
	|| (global.challenge == challenges.trinketless || global.challenge == challenges.patience) && submenu_scroll == 0
) {
	draw_set_color(c_white);
}

draw_text(84, 261, submenus[submenu_scroll + 2]);
draw_set_color(c_white);

// The font will still be fnt_main for the state-specific drawing.
fsm.draw();