if (global.player_created) {
	instance_destroy();
} else {
	facing = directions.right;
	global.player_created = true;
}