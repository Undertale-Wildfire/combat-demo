if (is_undefined(global.battle_transition_player)) {
	soul_x = global.battle_transition_x;
	soul_y = global.battle_transition_y;
} else {
	soul_x = global.battle_transition_x - 8;
	soul_y = global.battle_transition_y - 46;
}

soul_visible = false;
flicker_count = 0;

soul_moving = false;
soul_distance_x = 40 - soul_x;
soul_distance_y = 446 - soul_y;
soul_speed_x = soul_distance_x / 17;
soul_speed_y = soul_distance_y / 17;

alarm[0] = 1;
alarm[1] = 32;