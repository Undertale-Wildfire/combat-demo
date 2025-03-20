if (shake_x != 0) {
	mod_x = shake_x;
	
	if (shake_x < 0) {
		shake_x++;
	}
	
	shake_x = -shake_x;
}

if (shake_y != 0) {
	mod_y = shake_y;
	
	if (shake_y < 0) {
		shake_y++;
	}
	
	shake_y = -shake_y;
}

if (shake_x + shake_y != 0) {
	alarm[0] = 2;
}