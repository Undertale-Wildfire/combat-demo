// The player should move to the center of the ground (between Quigley and Anser).
in_position = false;

if (obj_player.y < 170) {
	obj_player.facing = directions.down;
} else if (obj_player.y > 170) {
	obj_player.facing = directions.up;
}

if (global.flags.quigley_anser_attempted || !is_undefined(global.challenge)) {
	// Use a shorter, dialogue-free version of the pre-fight cutscene if the player died previously.
	// We also do this if a challenge is being attempted, to save time.
	// Copying the cutscene and modifying it manually unfortunately seems like the best way to do this.
	cutscene = cutscene_init()
		.add(new ev_set(obj_camera, "focus", undefined))
		.add(new ev_move(obj_camera, 200, 0, 3, false))
		.add(new ev_music_fadeout(1))
		.add(new ev_timer(15))
		.add({initialize: function() {
			global.music_playing = audio_play_sound(mus_anser_quigley, 1, true);
		}})
		.add(new ev_set(obj_anser, "sprite_index", spr_anser_left))
		.add(new ev_set(obj_quigley, "sprite_index", spr_quigley_right))
		.add(new ev_set(obj_quigley, "image_xscale", -1))
		.add(new ev_sound(snd_encounter))
		.add(new ev_alert(obj_quigley))
		.add(new ev_alert(obj_anser), [-2])
		.add(new ev_timer(30))
		.add(new ev_set(obj_anser, "image_index", 1))
		.add(new ev_set(obj_anser, "image_speed", 1))
		.add(new ev_move(obj_anser, -30, 0, 1, true))
		.add(new ev_set(obj_anser, "sprite_index", spr_anser_battle_stance))
		.add(new ev_set(obj_anser, "image_speed", 0))
		.add(new ev_timer(15))
		.add(new ev_set(obj_quigley, "image_index", 1))
		.add(new ev_set(obj_quigley, "image_speed", 1))
		.add(new ev_move(obj_quigley, -30, 0, 1, true))
		.add(new ev_set(obj_quigley, "sprite_index", spr_quigley_battle_stance))
		.add(new ev_set(obj_quigley, "image_xscale", 1))
		.add(new ev_set(obj_quigley, "image_speed", 0))
		.add(new ev_timer(15))
		.add(new ev_music_fadeout(1))
		.add(new ev_timer(15), [-2])
		.add(new ev_set(obj_player, "image_index", 1))
		.add(new ev_set(obj_player, "image_speed", 1))
		.add(new ev_move(obj_player, 30, 0, 1, true))
		.add(new ev_set(obj_player, "image_index", 0))
		.add(new ev_set(obj_player, "image_speed", 0))
		.add(new ev_timer(15));
} else {
	cutscene = cutscene_init()
		.add(new ev_set(obj_camera, "focus", undefined))
		.add(new ev_move(obj_camera, 200, 0, 3, false))
		.add(new ev_music_fadeout(1))
		.add(new ev_timer(15))
		.add({initialize: function() {
			global.music_playing = audio_play_sound(mus_anser_quigley, 1, true);
		}})
		.add(new ev_dialogue(directions.up, [
			{face: {sprite: spr_face_anser, talk_sprite: spr_face_anser_talk, image: 6}, blip: snd_blip_anser, speaker: obj_anser.id, text: "A month...\nA whole month!"},
			{face: {sprite: spr_face_quigley, talk_sprite: noone, image: 6}, blip: snd_blip_quigley, speaker: noone, text: "A human was living among us for a {e,s}month{e,n}?"}
		]))
		.add(new ev_set(obj_anser, "sprite_index", spr_anser_left))
		.add(new ev_set(obj_quigley, "sprite_index", spr_quigley_right))
		.add(new ev_set(obj_quigley, "image_xscale", -1))
		.add(new ev_sound(snd_encounter))
		.add(new ev_alert(obj_quigley))
		.add(new ev_alert(obj_anser), [-2])
		.add(new ev_timer(15))
		.add(new ev_dialogue(directions.up, [
			{face: {sprite: spr_face_anser, talk_sprite: spr_face_anser_talk, image: 3}, blip: snd_blip_anser, speaker: obj_anser.id, text: "I knew something smelled off about you, Riley."},
			{face: {sprite: spr_face_quigley, talk_sprite: noone, image: 1}, blip: snd_blip_quigley, speaker: noone, text: "Likewise.\nBesides your lack of rabbit smell, that is."},
			{face: {sprite: spr_face_anser, talk_sprite: spr_face_anser_talk, image: 2}, blip: snd_blip_anser, speaker: obj_anser.id, text: "Hmph.\nYou may have helped around the village..."},
			{face: {sprite: spr_face_anser, talk_sprite: spr_face_anser_talk, image: 5}, blip: snd_blip_anser, speaker: obj_anser.id, text: "But you kept this from us."},
			{face: {sprite: spr_face_anser, talk_sprite: spr_face_anser_talk, image: 5}, blip: snd_blip_anser, speaker: obj_anser.id, text: "Clearly, you're dangerous and untrustworthy."},
			{face: {sprite: spr_face_quigley, talk_sprite: noone, image: 5}, blip: snd_blip_quigley, speaker: noone, text: "Rules are rules."},
			{face: {sprite: spr_face_quigley, talk_sprite: noone, image: 5}, blip: snd_blip_quigley, speaker: noone, text: "I feel conflicted, but... we answer to Asgore."},
			{face: {sprite: spr_face_quigley, talk_sprite: noone, image: 7}, blip: snd_blip_quigley, speaker: noone, text: "Any human who falls into the Underground must be apprehended."}
		]))
		.add(new ev_timer(15))
		.add(new ev_set(obj_anser, "image_index", 1))
		.add(new ev_set(obj_anser, "image_speed", 1))
		.add(new ev_move(obj_anser, -30, 0, 1, true))
		.add(new ev_set(obj_anser, "sprite_index", spr_anser_battle_stance))
		.add(new ev_set(obj_anser, "image_speed", 0))
		.add(new ev_timer(15))
		.add(new ev_set(obj_quigley, "image_index", 1))
		.add(new ev_set(obj_quigley, "image_speed", 1))
		.add(new ev_move(obj_quigley, -30, 0, 1, true))
		.add(new ev_set(obj_quigley, "sprite_index", spr_quigley_battle_stance))
		.add(new ev_set(obj_quigley, "image_xscale", 1))
		.add(new ev_set(obj_quigley, "image_speed", 0))
		.add(new ev_timer(15))
		.add(new ev_dialogue(directions.up, [
			{face: {sprite: spr_face_quigley, talk_sprite: noone, image: 2}, blip: snd_blip_quigley, speaker: noone, text: "Please, would you come peacefully?"},
			{face: {sprite: spr_face_quigley, talk_sprite: noone, image: 2}, blip: snd_blip_quigley, speaker: noone, text: "We don't want to fight you."}
		]))
		.add(new ev_music_fadeout(1))
		.add(new ev_timer(15), [-2])
		.add(new ev_set(obj_player, "image_index", 1))
		.add(new ev_set(obj_player, "image_speed", 1))
		.add(new ev_move(obj_player, 30, 0, 1, true))
		.add(new ev_set(obj_player, "image_index", 0))
		.add(new ev_set(obj_player, "image_speed", 0))
		.add(new ev_timer(15))
		.add(new ev_dialogue(directions.up, [
			{face: {sprite: spr_face_anser, talk_sprite: spr_face_anser_talk, image: 1}, blip: snd_blip_anser, speaker: obj_anser.id, text: "Of course you're not going to back down."},
			{face: {sprite: spr_face_anser, talk_sprite: spr_face_anser_talk, image: 4}, blip: snd_blip_anser, speaker: obj_anser.id, text: "Defying the law.\nTypical human behavior.\nVery well, then."},
			{face: {sprite: spr_face_anser, talk_sprite: spr_face_anser_talk, image: 5}, blip: snd_blip_anser, speaker: obj_anser.id, text: "Quigley!"},
			{face: {sprite: spr_face_anser, talk_sprite: spr_face_anser_talk, image: 5}, blip: snd_blip_anser, speaker: obj_anser.id, text: "We must stop Riley from encroaching any further!"},
			{face: {sprite: spr_face_quigley, talk_sprite: noone, image: 3}, blip: snd_blip_quigley, speaker: noone, text: "Right!\nI've got your back."}
		]));
	
	global.flags.quigley_anser_attempted = true;
}

cutscene
	.add({initialize: function() {
		// Prevents the trail music from playing when we first return to the room after the battle
		global.music = mus_trail;
	}})
	.add(new ev_battle(encounters.anser_quigley))
	.add({initialize: function() {
		// Like I wrote in the cutscene documentation, adding events mid-cutscene is something you should only
		// ever do if you're 100% sure you know what you're doing. I wouldn't consider it good practice.
		// ... that being said, it's probably the cleanest solution here.
		if (global.encounter.enemies[0].state == enemy_states.spared && global.encounter.enemies[1].state == enemy_states.spared) {
			obj_anser_quigley_cutscene.cutscene
				.add(new ev_timer(45))
				.add(new ev_set(obj_anser, "sprite_index", spr_anser_left))
				.add(new ev_timer(30))
				.add(new ev_set(obj_quigley, "sprite_index", spr_quigley_right))
				.add(new ev_set(obj_quigley, "image_xscale", -1))
				.add(new ev_timer(45))
				.add(new ev_set(obj_anser, "sprite_index", spr_anser_right))
				.add(new ev_timer(30))
				.add(new ev_set(obj_anser, "image_index", 1))
				.add(new ev_set(obj_anser, "image_speed", 1))
				.add(new ev_move(obj_anser, 30, 0, 1, true))
				.add(new ev_set(obj_anser, "sprite_index", spr_anser_left))
				.add(new ev_set(obj_anser, "image_index", 0))
				.add(new ev_set(obj_anser, "image_speed", 0))
				.add(new ev_timer(15))
				.add(new ev_dialogue(directions.up, [
					{face: {sprite: spr_face_anser, talk_sprite: spr_face_anser_talk, image: 6}, blip: snd_blip_anser, speaker: obj_anser.id, text: "What's this...\nYou defeated us, human."},
					{face: {sprite: spr_face_anser, talk_sprite: spr_face_anser_talk, image: 6}, blip: snd_blip_anser, speaker: obj_anser.id, text: "Do your worst.\nGo on, get it over with already."},
					{face: {sprite: spr_face_quigley, talk_sprite: noone, image: 0}, blip: snd_blip_quigley, speaker: noone, text: "They ended the fight."}
				]))
				.add(new ev_timer(15))
				.add(new ev_set(obj_quigley, "image_xscale", 1))
				.add(new ev_timer(15))
				.add(new ev_set(obj_quigley, "image_index", 1))
				.add(new ev_set(obj_quigley, "image_speed", 1))
				.add(new ev_move(obj_quigley, 30, 0, 1, true))
				.add(new ev_set(obj_quigley, "sprite_index", spr_quigley_down))
				.add(new ev_set(obj_quigley, "image_index", 0))
				.add(new ev_set(obj_quigley, "image_xscale", 1))
				.add(new ev_set(obj_quigley, "image_speed", 0))
				.add(new ev_timer(15))
				.add(new ev_dialogue(directions.up, [
					{face: {sprite: spr_face_quigley, talk_sprite: noone, image: 0}, blip: snd_blip_quigley, speaker: noone, text: "See, Anser?\nIt's just like Riley's always been."},
					{face: {sprite: spr_face_quigley, talk_sprite: noone, image: 0}, blip: snd_blip_quigley, speaker: noone, text: "Helpful and kind.\nThey're not a killer."},
					{face: {sprite: spr_face_anser, talk_sprite: spr_face_anser_talk, image: 0}, blip: snd_blip_anser, speaker: obj_anser.id, text: "... I see."},
					{face: {sprite: spr_face_anser, talk_sprite: spr_face_anser_talk, image: 3}, blip: snd_blip_anser, speaker: obj_anser.id, text: "Can this really be?\nA human who isn't a murderer?"},
					{face: {sprite: spr_face_quigley, talk_sprite: noone, image: 5}, blip: snd_blip_quigley, speaker: noone, text: "If that's the case, then Riley isn't a threat to Snowdown."},
					{face: {sprite: spr_face_quigley, talk_sprite: noone, image: 5}, blip: snd_blip_quigley, speaker: noone, text: "Right, Anser?"},
					{face: {sprite: spr_face_anser, talk_sprite: spr_face_anser_talk, image: 5}, blip: snd_blip_anser, speaker: obj_anser.id, text: "... that would be correct."}
				]))
				.add(new ev_script(function() {
					global.music_playing = audio_play_sound(mus_anser_quigley, 1, true);
				}))
				.add(new ev_dialogue(directions.up, [
					{face: {sprite: spr_face_anser, talk_sprite: spr_face_anser_talk, image: 3}, blip: snd_blip_anser, speaker: obj_anser.id, text: "Fine, then.\nI can admit when I'm wrong."},
					{face: {sprite: spr_face_anser, talk_sprite: spr_face_anser_talk, image: 4}, blip: snd_blip_anser, speaker: obj_anser.id, text: "Go on, Riley.\nContinue into the forest."}
				]))
				.add(new ev_set(obj_quigley, "sprite_index", spr_quigley_right))
				.add(new ev_set(obj_quigley, "image_xscale", -1))
				.add(new ev_dialogue(directions.up, [
					{face: {sprite: spr_face_quigley, talk_sprite: noone, image: 0}, blip: snd_blip_quigley, speaker: noone, text: "And, you know..."},
					{face: {sprite: spr_face_quigley, talk_sprite: noone, image: 0}, blip: snd_blip_quigley, speaker: noone, text: "We won't alert the rest of the Royal Guard, either."},
					{face: {sprite: spr_face_quigley, talk_sprite: noone, image: 0}, blip: snd_blip_quigley, speaker: noone, text: "As much as I think that rules should be followed..."},
					{face: {sprite: spr_face_quigley, talk_sprite: noone, image: 1}, blip: snd_blip_quigley, speaker: noone, text: "I think we can make an exception for you."},
					{face: {sprite: spr_face_anser, talk_sprite: spr_face_anser_talk, image: 1}, blip: snd_blip_anser, speaker: obj_anser.id, text: "Hmph.\nMaybe someday we can have a little rematch."},
					{face: {sprite: spr_face_anser, talk_sprite: spr_face_anser_talk, image: 1}, blip: snd_blip_anser, speaker: obj_anser.id, text: "You've got an amicable fighting spirit."}
				]))
				.add(new ev_music_fadeout(1))
				.add(new ev_timer(15), [-2])
				.add(new ev_set(obj_anser, "sprite_index", spr_anser_right))
				.add(new ev_timer(30))
				.add(new ev_set(obj_anser, "image_index", 1))
				.add(new ev_set(obj_anser, "image_speed", 1))
				.add(new ev_move(obj_anser, 540, obj_anser.y, 1, false))
				.add(new ev_timer(15), [-4])
				.add(new ev_set(obj_quigley, "image_xscale", 1))
				.add(new ev_timer(30))
				.add(new ev_set(obj_quigley, "image_index", 1))
				.add(new ev_set(obj_quigley, "image_speed", 1))
				.add(new ev_move(obj_quigley, 535, obj_quigley.y, 1, false))
				.add(new ev_destroyinst(obj_anser), [-6, -1])
				.add(new ev_destroyinst(obj_quigley))
				.add(new ev_move(obj_camera, 130, 0, 3, false))
				.add(new ev_set(obj_camera, "focus", obj_player))
				.add(new ev_script(function() {
					global.music = mus_trail;
					global.music_playing = audio_play_sound(mus_trail, 1, true);
				}));
			
			global.quigley_anser_outcome = quigley_anser_outcomes.spared_both;
		} else {
			obj_anser_quigley_cutscene.cutscene
				.add(new ev_timer(45))
				.add(new ev_move(obj_camera, 130, 0, 3, false))
				.add(new ev_set(obj_camera, "focus", obj_player));
			
			instance_destroy(obj_anser);
			instance_destroy(obj_quigley);
			
			if (global.encounter.enemies[0].state == enemy_states.spared) {
				if (global.encounter.enemies[0].state == enemy_states.spared && global.encounter.enemies[1].state == enemy_states.dead) {
					depth_add_instance(instance_create_layer(430, 180, "depth", obj_quigley_distraught));
					depth_add_instance(instance_create_layer(394, 176, "depth", obj_quigley_hat));
					depth_add_instance(instance_create_layer(437, 158, "depth", obj_quigley_binoculars));
					instance_create_layer(405, 152, "below_depth", obj_quigley_glasses);
				
					with (instance_create_layer(406, 163, "system", obj_interact_box, {image_xscale: 16, image_yscale: 5.666667})) {
						times_interacted = 0;
						
						function interact() {
							var text;
							switch (times_interacted) {
								case 0: text = "He's still breathing.\nHe'll be fine."; break;
								case 1: text = "None of his equipment is salvageable."; break;
								case 2: text = "Snow is slowly piling up on him."; break;
							}
							
							cutscene_init().add(new ev_dialogue(undefined, [{face: undefined, blip: snd_blip_generic, speaker: noone, text: text}])).start();
							
							if (times_interacted < 2) {
								times_interacted++;
							}
						}
					}
				}
				
				global.quigley_anser_outcome = quigley_anser_outcomes.killed_anser;
			} else {
				global.quigley_anser_outcome = quigley_anser_outcomes.killed_both;
			}
		}
	}});