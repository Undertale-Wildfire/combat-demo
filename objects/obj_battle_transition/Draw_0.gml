if (!soul_moving && !is_undefined(global.battle_transition_player)) {
	draw_sprite_ext(
		global.battle_transition_player.sprite,
		global.battle_transition_player.image,
		global.battle_transition_x,
		global.battle_transition_y,
		2,
		2,
		0,
		c_white,
		1
	);
}

if (soul_visible) {
	draw_sprite(spr_soul_small, 0, soul_x, soul_y);
}