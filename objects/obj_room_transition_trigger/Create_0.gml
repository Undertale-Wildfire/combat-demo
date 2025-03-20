event_inherited();

function trigger() {
	instance_create_layer(0, 0, "system", obj_room_transition, {
		new_room: new_room,
		new_x: new_x,
		new_y: new_y,
		new_direction: new_direction
	});
}