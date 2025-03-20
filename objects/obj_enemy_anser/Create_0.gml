center_y = y - 107;
damage_bar_y = y - 50;
vapor_sprite = spr_enemy_anser_knocked_down;

head = 3;
hand = 1;

bob_timer = 0.75;  // 0.75 is when the sprites are at their topmost position, which is where we want them to start.
tail_timer = 0;

// Given a progress value between 0 and 1, returns a value from -1 to 1 using a quadratic ease in/out function.
function ease_in_out_quad(progress) {
	return ((progress < 0.5 ? 2 * progress * progress : 1 - power(-2 * progress + 2, 2) / 2) - 0.5) * 2;
}

// talk_counter = 0;