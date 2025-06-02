_typewriter = undefined;

function ev_intro_text(_text) constructor {
	text = _text;
	
	static initialize = function() {
		obj_intro_scene._typewriter = new typewriter(fnt_main, 18, 36, 22, false, snd_blip_battle, false, noone, "{d,2}" + text);
	}
}

early_stop = false;
finished = false;

music = audio_play_sound(mus_intro, 50, false);

scene = cutscene_init();

slide = 1;
elapsed = 0;
insert_slide = function(timestamp, destroy = true) {
	var wait_time = timestamp - elapsed;
	
	scene
		.add(new ev_lerp_var(id, nameof(image_alpha), 0, 1, 0.05))
		.add(new ev_timer(wait_time * 30 - 38))  // Each ev_lerp_var lasts 19 frames.
		.add(new ev_lerp_var(id, nameof(image_alpha), 1, 0, 0.05))
		.add(new ev_set(id, nameof(image_index), slide++));
	
	if (destroy) {
		scene.add(new ev_script(function() {
			obj_intro_scene._typewriter = undefined;
		}));
	}
 
	elapsed = timestamp;
}

image_alpha = 0;
image_speed = 0;

draw_y = 0;

static_alpha = 0;
static_surface = undefined;

var music_beat_length = time_bpm_to_seconds(110);
var time_move_on = music_beat_length * 27;
var time_orphanage = music_beat_length * 31;
var time_gym = music_beat_length * 67;
var time_bridge = music_beat_length * 99;
var time_river = music_beat_length * 131;
var time_river_scroll_end = music_beat_length * 143;
var time_wake_up = music_beat_length * 147;
var time_footprints = music_beat_length * 163;
var time_static = music_beat_length * 183;
var time_end = audio_sound_length(mus_intro);

insert_slide(time_orphanage / 3);
insert_slide(time_orphanage / 3 * 2);
insert_slide(time_orphanage);
insert_slide(time_orphanage + (time_gym - time_orphanage) / 4, false);
insert_slide(time_orphanage + (time_gym - time_orphanage) / 2);
insert_slide(time_orphanage + (time_gym - time_orphanage) / 4 * 3, false);
insert_slide(time_gym);
insert_slide(time_gym + (time_bridge - time_gym) / 3);
insert_slide(time_gym + (time_bridge - time_gym) / 3 * 2);
insert_slide(time_gym + (time_bridge - time_gym) / 6 * 5, false);
insert_slide(time_bridge);
insert_slide(time_bridge + (time_river - time_bridge) / 3);
insert_slide(time_bridge + (time_river - time_bridge) / 2, false);
insert_slide(time_bridge + (time_river - time_bridge) / 3 * 2);
insert_slide(time_river);
insert_slide(time_wake_up);
insert_slide(time_wake_up + (time_footprints - time_wake_up) / 3, false);
insert_slide(time_wake_up + (time_footprints - time_wake_up) / 3 * 2, false);
insert_slide(time_footprints, false);
insert_slide(time_end, false);

// These events are inserted into the correct places in the cutscene.
// Each slide is 5 events long, or 4 events if "destroy" is set to false.
// Some of the dialogue lines span multiple slides, and so have specially calculated delays to sync up.
scene
	.add(new ev_intro_text("   RILEY'S JOURNAL\n  28 DAYS SINCE FALL"), [])
	.add(new ev_intro_text("Another bad dream.\nCan't forget about that day."), [4])
	.add(new ev_intro_text("Writing this, so I can reflect...\n{p," + string(floor((time_move_on - time_orphanage / 3 * 2) * 30 - 78)) + "}and move on."), [9])
	.add(new ev_intro_text("How did I feel when they kicked me out?"), [14])
	.add(new ev_intro_text("I was... happy.\n{p," + string(floor((time_gym - time_orphanage) / 4 * 30 - 42)) + "}Even though no one was waiting for me."), [23])
	.add(new ev_intro_text("Happy, with just my life's savings and a tournament ticket."), [32])
	.add(new ev_intro_text("I was ready to prove to everyone, and myself,"), [37])
	.add(new ev_intro_text("That my life was worth something,"), [42])
	.add(new ev_intro_text("That I had the power to change my fate."), [51])
	.add(new ev_intro_text("But when I looked up and saw that crescent eye,"), [56])
	.add(new ev_intro_text("How big and far it was, how small I was beneath it,"), [65])
	.add(new ev_intro_text("I knew, in my heart, that it wasn't worth trying anymore."), [70])
	// Some slides need to scroll.
	.add(new ev_lerp_var(id, "draw_y", 210, 0, 1 / ((time_river_scroll_end - time_river) * 30)), [70])
	.add(new ev_lerp_var(id, "draw_y", 0, 100, 1 / ((time_static - time_footprints) * 30)), [87])
	.add(new ev_lerp_var(id, "static_alpha", 0, 1, 1 / ((time_end - time_static) * 30)));

scene.start();