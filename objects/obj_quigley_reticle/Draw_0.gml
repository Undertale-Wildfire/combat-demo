if (circle_scale > 0) {
	draw_sprite_ext(spr_quigley_reticle_circle, 0, x, y, circle_scale, circle_scale, 0, c_white, 1);
} else {
	draw_sprite_ext(spr_quigley_reticle, reticle_image, x, y, 1, 1, 0, c_white, reticle_alpha);
}