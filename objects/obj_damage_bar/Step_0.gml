if (!text_stopped) {
	text_y_offset += text_speed;
	if (text_y_offset >= 0) {
		text_y_offset = 0;
		text_stopped = true;
	} else {
		text_speed += 0.5;
	}
}