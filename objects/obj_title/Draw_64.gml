if (orange_alpha > 0) {
	draw_set_alpha(orange_alpha);
	draw_set_color(#fca600);
	draw_rectangle(0, 0, 639, 479, false);
	draw_set_color(c_white);
	draw_set_alpha(1);
	
	orange_alpha -= 0.1;
}

if (show_text) {
	draw_set_color(c_gray);
	draw_set_font(fnt_small);
	draw_set_halign(fa_center);
	draw_text(320, 394, "[PRESS Z OR ENTER]");
	draw_set_halign(fa_left);
	draw_set_color(c_white);
}