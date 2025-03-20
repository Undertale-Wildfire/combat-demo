if (!is_undefined(_typewriter)) {
	_typewriter.step();
}

if (global.keys.confirm_pressed && !early_stop) {
	instance_destroy(scene);
	instance_create_layer(0, 0, "system", obj_fade, {type: fade_types.out, frames: 20});
	early_stop = true;
}

if (early_stop && !instance_exists(obj_fade)) {
	audio_stop_all();
	room_goto(rm_title);
}

if (!finished && !audio_is_playing(music)) {
	// I thought I calculated all the timestamps properly, but I guess not.
	// The static needs to disappear at the same time the song ends, though, so this will have to do until I
	// figure out what the actual issue is.
	instance_destroy(scene);
	
	finished = true;
	image_alpha = 0;
	static_alpha = 0;
	
	alarm[1] = 50;
}