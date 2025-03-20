fsm.end_step();

if (bp != old_bp) {
	bp_animation_progress = 0;
	last_visible_bp = visible_bp;
}

if (bp_animation_progress < 1) {
	bp_animation_progress += 0.1;
}

var difference = bp - last_visible_bp;
visible_bp = last_visible_bp + (bp_animation_progress == 1 ? 1 : 1 - power(2, bp_animation_progress * -10)) * difference;