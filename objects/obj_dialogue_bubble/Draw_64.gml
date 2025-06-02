if (!surface_exists(surface)) {
	// This includes extra room for the tail (12px on each side).
	surface = surface_create(pixel_width + 24, pixel_height + 24);
}

surface_set_target(surface);
draw_clear_alpha(c_black, 0);

// Draw rounded corners
draw_sprite(spr_dialogue_bubble_corner, 0, 13, 13);
draw_sprite_ext(spr_dialogue_bubble_corner, 0, 13, pixel_height + 11, 1, 1, 90, c_white, 1);
draw_sprite_ext(spr_dialogue_bubble_corner, 0, pixel_width + 11, pixel_height + 11, 1, 1, 180, c_white, 1);
draw_sprite_ext(spr_dialogue_bubble_corner, 0, pixel_width + 11, 13, 1, 1, 270, c_white, 1);

// Draw middle (this is probably faster than doing it in 5 rectangles without overlap?)
draw_rectangle(12, 26, pixel_width + 11, pixel_height - 3, false);
draw_rectangle(26, 12, pixel_width - 3, pixel_height + 11, false);

// Draw tail on correct side
switch (tail_side) {	
	case directions.right:
		draw_sprite_ext(spr_dialogue_bubble_tail, 0, pixel_width + 12, pixel_height div 2 + 12, -1, 1, 0, c_white, 1);
		break;
	
	case directions.up:
		draw_sprite_ext(spr_dialogue_bubble_tail, 0, pixel_width div 2 + 12, 12, 1, 1, 270, c_white, 1);
		break;
	
	case directions.left:
		draw_sprite(spr_dialogue_bubble_tail, 0, 12, pixel_height div 2 + 12);
		break
	
	case directions.down:
		draw_sprite_ext(spr_dialogue_bubble_tail, 0, pixel_width div 2 + 12, pixel_height + 12, 1, 1, 90, c_white, 1);
		break;
}

surface_reset_target();

draw_surface_ext(surface, x - 13, y - 12, 1, 1, 0, c_black, 1);
draw_surface_ext(surface, x - 11, y - 12, 1, 1, 0, c_black, 1);
draw_surface_ext(surface, x - 12, y - 13, 1, 1, 0, c_black, 1);
draw_surface_ext(surface, x - 12, y - 11, 1, 1, 0, c_black, 1);
draw_surface(surface, x - 12, y - 12);

// The typewriter text doesn't need to be drawn with an outline, so we can just draw it last.
_typewriter.draw(x + 7, y + 12);