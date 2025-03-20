function start_overworld_encounter(encounter_id) {
	// We don't set global.music to noone here so that the music doesn't restart when we return to the overworld
	// room after the encounter.
	audio_stop_sound(global.music_playing);
	
	global.encounter = get_encounter(encounter_id);
	global.battle_fade_type = battle_fade_types.screen;
	
	global.battle_transition_x = (obj_player.x - camera_get_view_x(view_camera[0])) * 2;
	global.battle_transition_y = (obj_player.y - camera_get_view_y(view_camera[0])) * 2;
	global.battle_transition_player = {
		sprite: obj_player.sprite_index,
		image: obj_player.image_index
	};
	
	// The current room should be the same as it is now when we return to it after the battle.
	global.battle_return_room = room;
	global.battle_return_room_reset = false;  // Whether to reset the room when we next return to it
	room_persistent = true;
	
	room_goto(rm_battle_transition);
}