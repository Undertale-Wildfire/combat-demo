var bullet_x;
var bullet_y;

switch (choose(directions.right, directions.up, directions.left, directions.down)) {
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
	dir: point_direction(bullet_x, bullet_y, obj_soul.x, obj_soul.y)
});

alarm[0] = 30;