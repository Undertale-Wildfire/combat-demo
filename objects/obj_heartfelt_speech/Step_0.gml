if (fading) {
	fade_out(0.05);
} else if (image_alpha < 1) {
	image_alpha += 0.05;
} else if (global.keys.confirm_pressed) {
	image_alpha -= 0.05;
	fading = true;
}