for (var i = 0; i < array_length(snowflakes); i++) {
	draw_sprite_ext(spr_trail_snowflakes, snowflakes[i].image, snowflakes[i]._x, snowflakes[i]._y, 1, 1, snowflakes[i].angle, c_white, snowflakes[i].alpha);
}