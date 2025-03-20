in_new_room = false;
fade = instance_create_layer(0, 0, "system", obj_fade, {type: fade_types.out, frames: 13});

// If the music track is going to change, fade the current one out
if (get_room_music(new_room) != global.music) {
	audio_sound_gain(global.music, 0, 1000 / 3);
}