var box = obj_battle_controller.box;
var center_points = [
	{_x: box.x1 - 81, _y: 320},
	{_x: box.x2 + 82, _y: 320},
	{_x: 320, _y: box.y1 - 81}
];

var ignore_values = array_shuffle([0, 1, 2]);
for (var i = 0; i < 3; i++) {
	var angle_offset = irandom_range(0, 40);
	for (var angle = 0; angle < 360; angle += 72) {
		instance_create_layer(center_points[i]._x, center_points[i]._y, "bullets", obj_bullet_anser_star, {
			above: true,
			move_type: star_move_types.circle,
			move_speed: 3,
			move_direction: angle,
			circle_radius: 50,
			homing_ignore: ignore_values[i]
		});
	}
	
	// The fact that creating a stationary star worked without issue is kind of baffling to me.
	instance_create_layer(center_points[i]._x, center_points[i]._y, "bullets", obj_bullet_anser_star, {
		above: true,
		move_type: star_move_types.circle,
		move_speed: 3,  // Needed so this star starts moving toward the SOUL at the same time as the others
		move_direction: 0,
		circle_radius: 0,
		homing_ignore: ignore_values[i]
	});
}

reticles_spawned = false;
alarm[0] = 30;