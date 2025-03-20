if (global.keys.menu_pressed) {
	selected_pattern = (selected_pattern + 1) % 10;
	global.pattern = patterns[selected_pattern].pattern;
}