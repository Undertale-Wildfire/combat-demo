if (!is_undefined(focus)) {
	// Keep focused instance in center of screen if possible
	// (This is in End Step to make sure the instance has moved before we center the camera on it.)
	// (The modifiers are allowed to move the camera out of bounds.)
	x = clamp(focus.x - 160, 0, room_width - 320);
	y = clamp(focus.y - 146, 0, room_height - 240);
}

camera_set_view_pos(view_camera[0], x + mod_x, y + mod_y);

// This prevents the menu's position being decided before the camera moves, which can cause dialogue boxes
// created later on by the menu to be placed under the rest of the GUI.
if (instance_exists(obj_player_menu) && !variable_instance_exists(obj_player_menu, "info_box_y")) {
	obj_player_menu.normal_info_box_y = (obj_player.y - 26 - camera_get_view_y(view_camera[0]) > 120) ? 322 : 52;
	obj_player_menu.info_box_y = obj_player_menu.normal_info_box_y;
}