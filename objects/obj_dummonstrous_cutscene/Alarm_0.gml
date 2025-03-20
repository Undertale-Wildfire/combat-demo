cutscene_init()
	.add(new ev_bubble(x + 44, y - 67, directions.left, 21, 4, [
		{blip: snd_blip_generic, speaker: noone, can_skip: false, text: "To win this game, you must first beat me..."},
		{blip: snd_blip_generic, speaker: noone, can_skip: false, text: "The powerful!\nAnd terrible!\n{d,3}DUMMONSTROUS!"},
		{blip: snd_blip_generic, speaker: noone, can_skip: false, text: "Have at you!"}
	]))
	.add({
		initialize: function() {
			global.encounter = get_encounter(encounters.dummonstrous);
			global.battle_fade_type = battle_fade_types.ui;
			global.battle_return_room = room;
			
			global.battle_transition_x = 320;
			global.battle_transition_y = 354;
			global.battle_transition_player = undefined;
			
			global.battle_return_room = room;
			global.battle_return_room_reset = false;
			room_persistent = true;

			instance_create_layer(0, 0, "system", obj_battle_transition);
		},
		step: function() {
			return instance_exists(obj_battle_transition);
		}
	})
	.add(new ev_destroyinst(id))
	.add(new ev_timer(30))
	.add({initialize: function() {
		global.combat_demo_flags.completed_tutorial = true;
		room_goto(rm_menu);
	}})
	.start();