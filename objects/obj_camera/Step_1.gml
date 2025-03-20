// It's nicer not to have to manually set obj_player as the focus in every overworld room.
if (!found_player && is_undefined(focus) && instance_exists(obj_player)) {
	focus = obj_player;
	found_player = true;
}