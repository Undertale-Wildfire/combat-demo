if (!in_position) {
	if (obj_player.y < 170) {
		obj_player.y += 1;
		if (obj_player.y >= 170) {
			obj_player.y = 170;
			in_position = true;
		}
	} else if (obj_player.y > 170) {
		obj_player.y -= 1;
		if (obj_player.y <= 170) {
			obj_player.y = 170;
			in_position = true;
		}
	} else {
		in_position = true;
	}
	
	if (in_position) {
		obj_player.facing = directions.right;
		cutscene.start();
	}
}