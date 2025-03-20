if (bbox_top > 480) {
	instance_destroy();
	exit;
}

if (speed > base_speed) {
	speed -= 0.2;
}

image_angle += spin_speed * spin_dir;