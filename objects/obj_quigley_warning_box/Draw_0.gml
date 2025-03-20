if (frame < 2) {
	if (frame == 0) {
		draw_set_color(c_red);
	} else {
		draw_set_color(c_yellow);
		audio_play_sound(snd_warning, 1, false);
	}
	
	if (side == directions.up) {
		draw_rectangle(x - 28, y + 3, x + 28, y + 56, true);
	} else {
		draw_rectangle(x - 28, y - 56, x + 28, y - 3, true);
	}
	
	draw_set_color(c_white);
}

draw_sprite(spr_exclamation_point, frame, x, side == directions.up ? y + 29.5 : y - 29.5);