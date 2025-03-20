if (!show_bar) {
	exit;
}

var damage_string = string(damage);
var damage_string_length = string_length(damage_string);
var left = x - (damage_string_length * 32 - 2) div 2;

for (var i = 1; i <= damage_string_length; i++) {
	draw_sprite(spr_damage_digits, real(string_char_at(damage_string, i)), left + (i - 1) * 32, y - 50 + text_y_offset);
}

draw_set_color(c_black);
draw_rectangle(x - 50, y - 14, x + 49, y, false);
draw_set_color(c_dkgray);
draw_rectangle(x - 49, y - 13, x + 48, y - 1, false);
draw_set_color(c_lime);
var green_bar_width = enemy.current_health / enemy.max_health * 98;
draw_rectangle(x - 49, y - 13, x - 50 + green_bar_width, y - 1, false);
draw_set_color(c_white);