if (soul_moving) {
	soul_x += soul_speed_x;
	soul_y += soul_speed_y;
	
	if (soul_x <= 40 || soul_y >= 446) {
		soul_x = 40;
		soul_y = 446;
	}
}