if (image_alpha > 0) {
	draw_sprite_part_ext(sprite_index, image_index, 0, floor(draw_y), 200, 110, x, y, image_xscale, image_yscale, image_blend, image_alpha);
}

if (static_alpha > 0) {
	if (!surface_exists(static_surface)) {
		static_surface = surface_create(200, 110);
	}
	
	surface_set_target(static_surface);
	draw_sprite_tiled(spr_static, irandom_range(0, 2), 0, 0);
	surface_reset_target();
	draw_surface_ext(static_surface, x, y, 1, 1, 0, c_white, static_alpha);
}