// Find largest possible scale factor
var width = display_get_width();
var height = display_get_height();
global.max_scale = min(width / 640, height / 480);
global.max_scale_integer = min(width div 640, height div 480);

// Load settings
global.settings = {
	window_scale: max(1, global.max_scale_integer - 1),
	integer_scaling: true,
	volume_music: 1,
	volume_sfx: 1
};

if (file_exists("settings.json")) {
	var buffer = buffer_load("settings.json");
	var json = buffer_read(buffer, buffer_string);
	buffer_delete(buffer);
	var data = json_parse(json);
	
	var names = struct_get_names(global.settings);
	var names_length = array_length(names);
	
	for (var i = 0; i < names_length; i++) {
		if (variable_struct_exists(data, names[i])) {
			variable_struct_set(global.settings, names[i], variable_struct_get(data, names[i]));
		}
	}
} else {
	// Create a default settings file if one doesn't exist
	var file = file_text_open_write("settings.json");
	file_text_write_string(file, json_stringify(global.settings));
	file_text_close(file);
}

// Music is stored in external .ogg files, so its gain can be changed with audiogroup_default.
// This is a bad way to do this. I'll figure something better out later, I'm just tired right now and don't
// feel like working something better out.
audio_group_set_gain(audiogroup_default, global.settings.volume_music * 0.75, 0);
audio_group_set_gain(audiogroup_sfx, global.settings.volume_sfx, 0);

// Load Combat Demo save data
global.combat_demo_flags = {
	seen_warning: false,
	completed_tutorial: false,
	unlocked_challenges: false,
	completed_challenges: {
		trinketless: false,
		stress_hurts: false,
		patience: false,
		one_hit_wonder: false
	},
	seen_secret_ending: false
};

if (file_exists("combat_demo.json")) {
	var buffer = buffer_load("combat_demo.json");
	var json = buffer_read(buffer, buffer_string);
	buffer_delete(buffer);
	var data = json_parse(json);
	
	var names = struct_get_names(global.combat_demo_flags);
	var names_length = array_length(names);
	
	for (var i = 0; i < names_length; i++) {
		if (variable_struct_exists(data, names[i])) {
			variable_struct_set(global.combat_demo_flags, names[i], variable_struct_get(data, names[i]));
		}
	}
} else {
	// Create a default save file if one doesn't exist
	var file = file_text_open_write("combat_demo.json");
	file_text_write_string(file, json_stringify(global.combat_demo_flags));
	file_text_close(file);
}

// Find screen offsets
global.offset_x = (width - 640 * global.max_scale) div 2;
global.offset_x_integer = (width - 640 * global.max_scale_integer) div 2;
global.offset_y_integer = (height - 480 * global.max_scale_integer) div 2;

// Set window properties
window_set_fullscreen(false);
window_set_size(640 * global.settings.window_scale, 480 * global.settings.window_scale);
window_center();

quit_timer = 0;

audio_group_load(audiogroup_sfx);
audio_group_loaded = false;