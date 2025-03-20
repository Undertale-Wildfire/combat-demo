draw_set_alpha(0.5);
draw_set_color(c_black);
draw_rectangle(0, 0, 639, 64, false);
draw_set_color(c_white);
draw_set_alpha(1);

draw_formatted_text(2, 2, format_bubble,
	"Selected pattern: {c,lb}" + object_get_name(patterns[selected_pattern].pattern)
	+ "\n{c,gr}" + patterns[selected_pattern].description
	+ "\n{c,gy}(C to switch pattern)"
);