var available_directions = [directions.right, directions.up, directions.left, directions.down];
array_delete(available_directions, irandom_range(0, 3), 1);
array_delete(available_directions, irandom_range(0, 2), 1);

for (var i = 0; i < 2; i++) {
	var bullet_x;
	var bullet_y;
	
	switch (choose(directions.left, directions.right, directions.up, directions.down)) {
		case directions.right:
			bullet_x = 413;
			bullet_y = irandom_range(258, 381);
			break;
	
		case directions.up:
			bullet_x = irandom_range(258, 381);
			bullet_y = 226;
			break;
	
		case directions.left:
			bullet_x = 226;
			bullet_y = irandom_range(258, 381);
			break;
	
		case directions.down:
			bullet_x = irandom_range(258, 381);
			bullet_y = 413;
			break;
	}
	
	instance_create_layer(bullet_x, bullet_y, "bullets", obj_bullet_dummonstrous, {
		above: true,
		dir: point_direction(bullet_x, bullet_y, 320, 320) + random_range(-10, 10),
		bounce: true
	});
}

alarm[0] = 150;