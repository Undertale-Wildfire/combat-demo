/*
Events follow a simple format, so adding more if necessary should be simple.
Each event is a struct containing the methods initialize() and step(). Both are optional.

initialize() is called when the event is started.

step() is called once per frame while the event is running.
If it returns true, the event will continue on the next frame.
If it returns false, the event will end.
If this function is not present, the event will end immediately after initialization.
*/

// Counts down for a certain amount of frames.
function ev_timer(_frames) constructor {
	// .step() is run on the same frame as the event is started, so if we didn't add 1 to the frame count
	// we would always wait for one less frame than intended.
	frames = _frames + 1;
	
	static step = function() {
		frames--;
		return frames > 0;
	}
}

// Creates a dialogue box.
function ev_dialogue(_side, _pages) constructor {
	side = _side;
	pages = _pages;
	
	static initialize = function() {
		dialogue_box = create_dialogue(side, pages);
	}
	
	static step = function() {
		return instance_exists(dialogue_box);
	}
}

// Creates a "basic" dialogue box (no portrait, automatically aligned).
function ev_dialogue_basic(_pages, _speaker = noone) constructor {
	pages = _pages;
	speaker = _speaker;
	
	static initialize = function() {
		dialogue_box = create_dialogue_basic(pages, speaker);
	}
	
	static step = function() {
		return instance_exists(dialogue_box);
	}
}

// Creates dialogue as seen in the box within battles (used for flavor text, ACT text, item use text, etc).
function ev_dialogue_battle(_pages) constructor {
	pages = _pages;
	
	static initialize = function() {
		dialogue = instance_create_layer(0, 0, "system", obj_dialogue_battle, {pages: pages});
	}
	
	static step = function() {
		return instance_exists(dialogue);
	}
}

// Moves an instance linearly.
// If rel is true, target_x and target_y are added to the instance's position instead of replacing it.
function ev_move(_instance, _target_x, _target_y, _spd, _rel = false) constructor {
	instance = _instance;
	target_x = _target_x;
	target_y = _target_y;
	spd = _spd;
	rel = _rel;
	
	static initialize = function() {
		// Calculate target position if applicable
		if (rel) {
			target_x += instance.x;
			target_y += instance.y;
		}
		
		// Calculate how far to move each step
		var angle = point_direction(instance.x, instance.y, target_x, target_y);
		step_x = lengthdir_x(spd, angle);
		step_y = lengthdir_y(spd, angle);
		sign_x = sign(step_x);
		sign_y = sign(step_y);
	}
	
	static step = function() {
		instance.x += step_x;
		instance.y += step_y;
		
		// Don't move past the target!
		if (sign_x == 1 && instance.x > target_x || sign_x == -1 && instance.x < target_x) {
			instance.x = target_x;
		}
			
		if (sign_y == 1 && instance.y > target_y || sign_y == -1 && instance.y < target_y) {
			instance.y = target_y;
		}
			
		return (instance.x != target_x || instance.y != target_y);
	}
}

// Sets a variable on an instance.
function ev_set(_instance, _variable, _value) constructor {
	instance = _instance;
	variable = _variable;
	value = _value;
	
	static initialize = function() {
		variable_instance_set(instance, variable, value);
	}
}

// Lerps an instance variable between 2 values
function ev_lerp_var(_instance, _variable, _start, _stop, _stepamt) constructor {
	instance = _instance;
	variable = _variable;
	initial = _start;
	goal = _stop;
	stepamt = _stepamt;
	
	progress = 0;
	
	static step = function() {
		if (abs(progress) >= 1) {
			return false;	
		}
		progress += stepamt;
		variable_instance_set(instance, variable, lerp(initial, goal, progress));
		return abs(progress) < 1;
	}
}

// Calls a function with the given (optional) args
function ev_script(_func, _args = []) constructor {
	func = _func;
	args = _args;
	
	static initialize = function() {
		script_execute_ext(func, args);
	}
}

function ev_destroyinst(_instance) constructor {
	instance = _instance;
	
	static initialize = function() {
		instance_destroy(instance);	
	}
}

// Plays a sound a single time.
// (This event is non-blocking, since I believe that is what is needed most often. Feel free to add an e_sound_blocking event if required.)
function ev_sound(_sound) constructor {
	sound = _sound;
	
	static initialize = function() {
		audio_play_sound(sound, 1, false);
	}
}

// Creates a dialogue bubble. Meant for use only in battles.
function ev_bubble(_tail_x, _tail_y, _tail_side, _width, _height, _pages) constructor {
	tail_x = _tail_x;
	tail_y = _tail_y;
	tail_side = _tail_side;
	width = _width;
	height = _height;
	pages = _pages;
	
	static initialize = function() {
		bubble = create_dialogue_bubble(tail_x, tail_y, tail_side, width, height, pages);
	}
	
	static step = function() {
		return instance_exists(bubble);
	}
}

// Fades the screen in from or out to a specific color.
function ev_fade(_type, _frames, _color = c_black) constructor {
	type = _type;
	frames = _frames;
	color = _color;
	
	static initialize = function() {
		fade = instance_create_layer(0, 0, "system", obj_fade, {
			type: type,
			frames: frames,
			color: color
		});
	}
	
	static step = function() {
		return instance_exists(fade);
	}
}

// Fades the current music track out.
function ev_music_fadeout(_seconds = 1 / 3) constructor {
	seconds = _seconds;
	
	static initialize = function() {
		do_nothing = (audio_sound_get_gain(global.music_playing) == 0);
		if (!do_nothing) {
			audio_sound_gain(global.music_playing, 0, seconds * 1000);
		}
	}
	
	static step = function() {
		if (do_nothing) {
			return false;
		} else if (audio_sound_get_gain(global.music_playing) == 0) {
			audio_stop_sound(global.music_playing);
			global.music = noone;
				
			return false;
		} else {
			return true;
		}
	}
}

// Starts a given encounter.
// (While this event changes the current room, the previous room is temporarily set as persistent during the
// battle, so the cutscene will continue afterward. However, because the room is changed, other events will
// not be able to run during the battle, so this event effectively appears to the rest of the cutscene as if
// it is one frame long. There may be a better way to do this, but for now this seems like the best solution
// to trigger scripted battles.)
function ev_battle(_encounter) constructor {
	encounter = _encounter;
	
	static initialize = function() {
		start_overworld_encounter(encounter);
		running = false;
	}
	
	static step = function() {
		// Run for one frame (to prevent later events starting before we change rooms)
		running = !running;
		return running;
	}
}

// Shakes an instance horizontally.
function ev_shake(_instance, _magnitude) constructor {
	instance = _instance;
	magnitude = _magnitude;
	
	static initialize = function() {
		dir = 1;
		base_x = instance.x;
	}
	
	static step = function() {
		instance.x = base_x + magnitude * dir;
		
		if (magnitude == 0) {
			return false;
		} else {
			--magnitude;
			dir *= -1;
		}
		
		return true;
	}
}

// Displays the alert/encounter exclamation mark above an instance.
function ev_alert(_instance) constructor {
	instance = _instance;
	
	static initialize = function() {
		// The system layer is always above everything else, so it works best for this.
		alert = instance_create_layer(instance.x, instance.y - instance.sprite_yoffset, "system", obj_alert);
	}
	
	static step = function() {
		return instance_exists(alert);
	}
}