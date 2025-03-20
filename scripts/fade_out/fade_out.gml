function fade_out(amount) {
	image_alpha -= amount;
	if (image_alpha <= 0) {
		instance_destroy();
	}
}