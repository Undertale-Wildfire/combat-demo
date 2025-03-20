cutscene_init()
	.add(new ev_timer(15))
	.add(new ev_sound(snd_challenge_complete))
	// We can't use ev_dialogue_basic here, since there's no player in the room.
	.add(new ev_dialogue(directions.down, [{
		face: undefined,
		blip: snd_blip_generic,
		speaker: noone,
		text: "Challenge {c,y}" + ["Trinketless", "Stress Hurts", "Patience", "One Hit Wonder"][global.challenge] + "{c,w} complete!"
	}]))
	.add({initialize: function() {
		if (
			global.combat_demo_flags.completed_challenges.trinketless
			&& global.combat_demo_flags.completed_challenges.stress_hurts
			&& global.combat_demo_flags.completed_challenges.patience
			&& global.combat_demo_flags.completed_challenges.one_hit_wonder
			&& !global.combat_demo_flags.seen_secret_ending
		) {
			obj_cutscene
				.add(new ev_timer(90))
				.add({initialize: function() {
					instance_create_layer(320, 240, "system", obj_explosion, {image_xscale: 2, image_yscale: 2});
				}})
				.add(new ev_timer(4))  // Wait until the explosion will cover the bnuuy to create it
				.add({
					initialize: function() {
						instance_create_layer(320, 240, "bnuuy", obj_bnuuy, {image_xscale: 2, image_yscale: 2});
					},
					step: function() {
						return instance_exists(obj_explosion);
					}
				})
				.add(new ev_timer(45))
				.add(new ev_bubble(355, 240, directions.left, 21, 4, [
					{blip: snd_blip_generic, speaker: noone, can_skip: true, text: "Haha, wow, you found me!"},
					{blip: snd_blip_generic, speaker: noone, can_skip: true, text: "Or, to be more accurate, {e,w}I{e,n} found {e,w}you{e,n}."},
					{blip: snd_blip_generic, speaker: noone, can_skip: true, text: "Congratulations are in order, I see."},
					{blip: snd_blip_generic, speaker: noone, can_skip: true, text: "You did everything this little world offered to you."},
					{blip: snd_blip_generic, speaker: noone, can_skip: true, text: "Those two sure were a lot of fun to mess with, weren't they?"},
					{blip: snd_blip_generic, speaker: noone, can_skip: true, text: "..."},
					{blip: snd_blip_generic, speaker: noone, can_skip: true, text: "Oh, are you expecting a reward?"},
					{blip: snd_blip_generic, speaker: noone, can_skip: true, text: "A trophy commemorating this {e,w}monumental{e,n} achievement?"},
					{blip: snd_blip_generic, speaker: noone, can_skip: true, text: "Haha, sorry, we only have confetti."}
				]))
				.add(new ev_sound(snd_party_horn))
				.add({
					initialize: function() {
						repeat (150) {
							instance_create_layer(irandom_range(-7, 647), irandom_range(-108, -8), "confetti", obj_confetti);
						}
					},
					step: function() {
						return instance_exists(obj_confetti);
					}
				})
				.add(new ev_timer(30))
				.add(new ev_bubble(355, 240, directions.left, 21, 4, [
					{blip: snd_blip_generic, speaker: noone, can_skip: true, text: "How fun."}
				]))
				.add(new ev_timer(60))
				.add(new ev_bubble(355, 240, directions.left, 21, 4, [
					{blip: snd_blip_generic, speaker: noone, can_skip: true, text: "Well, that's all. Honest."},
					{blip: snd_blip_generic, speaker: noone, can_skip: true, text: "You've done all we can offer you..."},
					{blip: snd_blip_generic, speaker: noone, can_skip: true, text: "... but by all means, don't let that stop you from continuing, if you so desire."},
					{blip: snd_blip_generic, speaker: noone, can_skip: true, text: "I'll be off, now."},
					{blip: snd_blip_generic, speaker: noone, can_skip: true, text: "But before I take my leave... I must express my eternal gratitude."}
				]))
				.add({
					initialize: function() {
						speech = instance_create_layer(320, 240, "system", obj_heartfelt_speech, {image_xscale: 2, image_yscale: 2});
					},
					step: function() {
						return instance_exists(speech);
					}
				})
				.add(new ev_timer(30))
				.add(new ev_bubble(355, 240, directions.left, 21, 4, [
					{blip: snd_blip_generic, speaker: noone, can_skip: true, text: "Well..."},
					{blip: snd_blip_generic, speaker: noone, can_skip: true, text: "See you around."}
				]))
				.add(new ev_sound(snd_mystery))
				.add(new ev_lerp_var(obj_bnuuy, "image_alpha", 1, 0, 0.2))
				.add(new ev_timer(120))
				.add({initialize: function() {
					global.combat_demo_flags.seen_secret_ending = true;
					room_goto(rm_menu);
				}})
				.start();
		} else {
			room_goto(rm_menu);
		}
	}})
	.start();

if (global.challenge == challenges.one_hit_wonder) {
	array_delete(global.unlocked_trinkets, 0, 1);
}