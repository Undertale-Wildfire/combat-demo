if (echo_timer > 0) {
	var echo_1_offset = (1 - power(1 - min(echo_timer / 8, 1), 3)) * 12;
	var echo_2_offset = (1 - power(1 - echo_timer / 16, 3)) * 24;
	
	draw_sprite_ext(spr_title_wildfire_echo, 0, x - 234 + echo_2_offset, y - 6 + echo_2_offset, 6, 6, 0, #5b0f00, 1);	
	draw_sprite_ext(spr_title_wildfire_echo, 0, x - 234 + echo_1_offset, y - 6 + echo_1_offset, 6, 6, 0, #7c2700, 1);
}

draw_sprite_ext(sprite_index, 0, x, y, image_xscale * 3, image_yscale * 3, 0, image_blend, image_alpha);

if (challenge_complete || fading) {
	draw_set_alpha(image_alpha);
	challenge_typewriter.draw(40, 307);
	draw_set_alpha(1);
}