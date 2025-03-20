function trigger() {
	if (is_undefined(global.challenge)) {
		cutscene_init()
			.add({initialize: function() {
				audio_stop_sound(global.music_playing);
			}})
			.add(new ev_sound(snd_buildup))
			.add(new ev_fade(fade_types.out, 156, c_white))
			.add({initialize: function() {
				room_goto(rm_credits);
			}})
			.start();
	} else {
		switch (global.challenge) {
			case challenges.trinketless: global.combat_demo_flags.completed_challenges.trinketless = true; break;
			case challenges.stress_hurts: global.combat_demo_flags.completed_challenges.stress_hurts = true; break;
			case challenges.patience: global.combat_demo_flags.completed_challenges.patience = true; break;
			case challenges.one_hit_wonder: global.combat_demo_flags.completed_challenges.one_hit_wonder = true; break;
		}
		
		cutscene_init()
			.add(new ev_music_fadeout(1))
			.add(new ev_fade(fade_types.out, 30))
			.add({initialize: function() {
				room_goto(rm_challenge_complete);
			}})
			.start();
	}
}