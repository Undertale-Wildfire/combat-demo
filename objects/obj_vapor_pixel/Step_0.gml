if (delay > 0) {
	delay--;
} else {
	speed_y -= grav;
	x += speed_x;
	y += speed_y;
	
	image_alpha -= 1 / 13;
	if (image_alpha <= 0) {
		instance_destroy();
	}
}