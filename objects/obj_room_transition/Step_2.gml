if (!instance_exists(fade)) {
	if (in_new_room) {
		instance_destroy();
	} else {
		room_goto(new_room);
		in_new_room = true;
		
		// Without using an alarm, the player and fade object will be created in the room we're leaving
		alarm[0] = 1;
	}
}