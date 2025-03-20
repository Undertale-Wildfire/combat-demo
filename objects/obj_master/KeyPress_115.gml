// Don't draw the application surface automatically if we're in fullscreen.
// This is needed so integer scaling can be handled manually.
if (window_get_fullscreen()) {
	window_set_fullscreen(false);
	display_set_gui_maximize(global.settings.window_scale, global.settings.window_scale, 0, 0);
	
	call_later(10, time_source_units_frames, function() {
		window_center();
	});
	
	if (global.settings.integer_scaling) {
		application_surface_draw_enable(true);
	}
} else {
	window_set_fullscreen(true);
	
	if (global.settings.integer_scaling) {
		application_surface_draw_enable(false);
		display_set_gui_maximize(global.max_scale_integer, global.max_scale_integer, global.offset_x_integer, global.offset_y_integer);
	} else {
		display_set_gui_maximize(global.max_scale, global.max_scale, global.offset_x, 0);
	}
}