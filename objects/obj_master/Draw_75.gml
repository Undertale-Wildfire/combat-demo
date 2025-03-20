// obj_fade should really just be removed. It would be better if obj_master handled fades instead.
// I'll leave it for now, since the current system does work, but will eventually change it.
with (obj_fade) {
	draw_set_alpha(type == fade_types.in ? 1 - progress / frames : progress / frames);
	draw_set_color(color);
	draw_rectangle(0, 0, 639, 479, false);
	draw_set_color(c_white);
	draw_set_alpha(1);
	
	// This is necessary to make the battle transition look correct.
	if (draw_soul) {
		with (obj_soul) {
			event_perform(ev_draw, ev_draw_normal);
		}
	}
}

if (quit_timer > 0) {
	draw_sprite_ext(spr_quit, floor(quit_timer / 20 * 2), 0, 0, 2, 2, 0, c_white, min(quit_timer / 10, 1));
}