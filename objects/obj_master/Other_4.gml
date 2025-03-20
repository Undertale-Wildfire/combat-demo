// If we're returning from a battle, we need to manually start a fade because we're not in a room transition.
// The room also needs to be made non-persistent again, since that's only needed when first returning.
if (room == global.battle_return_room) {
	room_persistent = false;
	global.battle_return_room = noone;
	
	if (global.battle_return_room_reset) {
		global.music = noone;
		audio_stop_sound(global.music_playing);
		room_restart();
	} else if (room != rm_title && room != rm_tutorial) {  // No need to start a fade after the tutorial; the screen's already black
		instance_create_layer(0, 0, "system", obj_fade, {type: fade_types.in, frames: 13});
	}
}

// global.music should not change during battles, so that the music doesn't restart automatically afterward
// (This will break music after random encounters, but that's a problem for when there _are_ random encounters.)
// TODO: Make this work for random encounters (or maybe just manually start the music again after random encounters?)
// Actually, the music should probably _pause_ during battles, so it can be resumed at the same point later.
// I'll figure this out at some point. Not right now.
if (room != rm_battle_transition && room != rm_battle) {
	var new_music = get_room_music(room);
	if (new_music != global.music) {
		// Fadeouts are handled in obj_room_transition before this
		global.music = new_music;
		audio_stop_sound(global.music_playing);
		
		if (global.music != noone) {
			global.music_playing = audio_play_sound(global.music, 1, true);
		}
	}
}