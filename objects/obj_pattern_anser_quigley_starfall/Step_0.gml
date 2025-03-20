if (stars_shot == 12 && !dog_triggered) {
	var all_outside_box = true;
	with (obj_bullet_anser_star) {
		if (bbox_top <= obj_battle_controller.box.y2) {
			all_outside_box = false;
		}
	}
	
	if (all_outside_box) {
		dog_triggered = true;
		alarm[1] = 30;
	}
}