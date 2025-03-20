draw_self();

if (graze_timer > 0) {
	draw_sprite_ext(spr_graze, global.stats.bravery, x, y, 1, 1, 0, #7F5300, graze_timer / 6);
	draw_sprite_ext(spr_graze, global.stats.bravery, x, y, 1, 1, 0, c_white, graze_timer / 6 - 0.2);
}