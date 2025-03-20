if (fading) {
	alpha -= 0.05;
	if (alpha == 0) {
		alarm[0] = 30;
	}
} else if (alpha < 1) {
	alpha += 0.05;
} else if (global.keys.confirm_pressed) {
	alpha -= 0.05;
	fading = true;
}