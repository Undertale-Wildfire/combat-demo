if (window_get_fullscreen() && global.settings.integer_scaling) {
	draw_surface_ext(application_surface, global.offset_x_integer, global.offset_y_integer, global.max_scale_integer, global.max_scale_integer, 0, c_white, 1);
}