if (bullets_spawned < 3) {
	instance_create_layer(
		0,
		obj_battle_controller.box.y1 + 39 + [0, 2, 1][bullets_spawned] * 64,
		"top",
		obj_anser_warning_box,
		{side: bullets_spawned == 1 ? directions.right : directions.left}
	);
	
	bullets_spawned++;
	alarm[0] = 40;
} else if (bullets_spawned < 6) {
	instance_create_layer(
		obj_battle_controller.box.x1 + 20 + [0, 2, 1][bullets_spawned - 3] * 25,
		0,
		"top",
		obj_anser_warning_line
	);
	
	if (++bullets_spawned < 6) {
		alarm[0] = 40;
	} else {
		alarm[0] = 23;  // This is the length of the warning box animation.
	}
} else {
	all_bullets_spawned = true;
}