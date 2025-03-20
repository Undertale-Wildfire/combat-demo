snowflakes = [];
spawn_chance = room_width / 320 * 0.1;  // More snowflakes need to spawn in longer rooms

// It looks weird if the room isn't initially filled with snowflakes, so we spawn a bunch in here.
// 1.5 is the average speed of a snowflake, so room_height / 1.5 is the average number of frames required for a
// snowflake to reach the bottom of the room.
repeat (room_height div 1.5) {
	event_perform(ev_step, ev_step_normal);
}