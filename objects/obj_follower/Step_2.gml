// This is in End Step to avoid frame delays.

if (obj_player.moving) {
	var latest = obj_player.follow_queue[0];

	x = latest._x;
	y = latest._y;
	facing = latest.facing;
}