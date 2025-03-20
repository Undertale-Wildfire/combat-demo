_typewriter.step();

// Advance page / close bubble on confirmation
if (global.keys.confirm_pressed && _typewriter.shown_chars == _typewriter.text_length) {
	if (++current_page < pages_length) {
		_typewriter = new typewriter(format_bubble, width, false, pages[current_page].blip, pages[current_page].can_skip, pages[current_page].speaker, pages[current_page].text);
	} else {
		instance_destroy();
	}
}