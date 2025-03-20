event_inherited();
enemy = 1;

enum star_move_types {
	straight,
	circle,
	wave
}

image_index = irandom_range(0, 2); // I think it looks better when the stars aren't rotating in sync.
image_alpha = 0;

if (move_type == star_move_types.circle) {
	center_x = x;
	center_y = y;
	
	// The Step event isn't guaranteed to run before the star is first drawn, so to avoid it appearing in the
	// wrong place for a frame we need to set its position here.
	x = center_x + lengthdir_x(160, move_direction);
	y = center_y + lengthdir_y(160, move_direction);
}

slowing_down = false;
homing = false;

particles = [];

function custom_draw() {
	for (var i = 0; i < array_length(particles); i++) {
		var particle = particles[i];
		draw_set_alpha(i / 11 * image_alpha);
		draw_rectangle(particle._x, particle._y, particle._x + particle.size, particle._y + particle.size, false);
	}
	
	draw_set_alpha(1);
	draw_self();
}