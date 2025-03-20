if (frame < 2) {
	if (frame == 0) {
		draw_set_color(c_red);
	} else {
		draw_set_color(c_yellow);
		audio_play_sound(snd_warning, 1, false);
	}
	
	draw_rectangle(obj_battle_controller.box.x1 + 7, y - 29, obj_battle_controller.box.x2 - 7, y + 28, true);
	draw_set_color(c_white);
}

draw_sprite(spr_exclamation_point, frame, side == directions.left ? obj_battle_controller.box.x1 + 20 : obj_battle_controller.box.x2 - 19, y);