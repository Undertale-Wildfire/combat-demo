if (!is_undefined(ui_surface)) {
	surface_free(ui_surface);
}

// The HP draining in the Stress Hurts challenge results in a decimal value, which shouldn't be kept after the
// battle is finished.
if (global.challenge == challenges.stress_hurts) {
	global.stats.current_health = ceil(global.stats.current_health);
}