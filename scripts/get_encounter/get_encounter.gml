enum encounters {
	dummonstrous,
	anser_quigley
}

function get_encounter(encounter_id) {
	switch (encounter_id) {
		case encounters.dummonstrous:
			return {
				enemies: [
					{
						name: "Dummonstrous",
						object: obj_enemy_dummonstrous,
						_x: 320,
						_y: 230,
						max_health: 300,
						attack: 10,
						defense: 0,
						default_kill: false,
						spareable: true,
						invulnerable: false,
						description: [
							"Loud guardian of the Combat Demo.",
							"Can only deal 1 damage with its low ATK."
						],
						execution_points: 10,
						gold: 20
					},
				],
				player_turn: function() {
					if (!initialized) {
						music = audio_play_sound(mus_battle, 50, true);
						initialized = true;
					}
					
					var flavor_text;
					if (first_turn) {
						flavor_text = "Dummonstrous blocks the way!";
					} else if (enemies[0].state == enemy_states.knocked_down) {
						flavor_text = "You've been hurt enough.";
					} else if (transformed) {
						flavor_text = choose(
							"The area darkens...",
							"Fear lingers over you.",
							"Pain is the best teacher.",
							"Nothing left to do but fight."
						);
					} else {
						flavor_text = choose(
							"Dummonstrous judges you intensely for no particular reason.",
							"Dummonstrous seems unimpressed.",
							"Dummonstrous impatiently repeats things you already know.",
							"Dummonstrous is annoyed by your bad stance."
						);
					}
					
					var acts = [
						{
							name: "Talk",
							cutscene: cutscene_init()
								.add(new ev_dialogue_battle([
									"You talk to Dummonstrous.",
									"It doesn't seem much for conversation."
								]))
						},
						{
							name: "Cover Mouth",
							cutscene: cutscene_init()
								.add(new ev_dialogue_battle(["You cover your mouth to remain silent."]))
						}
					];
					
					if (enemies[0].state == enemy_states.alive) {
						if (transformed) {
							acts[0].cutscene.add(new ev_sound(snd_growl))
								.add(new ev_dialogue_battle([
									"In fact, it seems much angrier than before...",
									"Dummonstrous' AT is increased!"
								]), [0])
								.add(new ev_script(function() {
									global.encounter.enemies[0].attack = 20;
									global.encounter.attack_mod_turns_remaining = 2;
								}));
							
							acts[1].cutscene
								.add(new ev_dialogue_battle([
									"Dummonstrous' thrashing slows down...",
									"Dummonstrous' DF drops to 0!"
								]))
								.add(new ev_script(function() {
									global.encounter.enemies[0].defense = 0;
									global.encounter.defense_mod_turns_remaining = 2;
								}));
						} else {
							acts[0].cutscene.add(new ev_dialogue_battle(["Nobody seems happy with this."]), [0]);
							acts[1].cutscene.add(new ev_dialogue_battle(["Nothing happens...\nWhy did you do that?"]));
						}
					} else {
						// The only other possible state here is knocked down.
						acts[1].cutscene.add(new ev_dialogue_battle(["Dummonstrous is too exhausted to care."]));
					}
					
					return {
						flavor_text: flavor_text,
						acts: [acts],
						win_check: {
							spared: true,
							dead: false
						},
						can_flee: false
					};
				},
				check: function(enemy) {
					if (!transformed && !seen_dialogue.check) {
						seen_dialogue.check = true;
						return cutscene_init()
							.add(new ev_bubble(global.encounter.enemies[0].instance.x + 44, global.encounter.enemies[0].instance.y - 67, directions.left, 21, 4, [
								{blip: snd_blip_generic, speaker: noone, can_skip: true, text: "Checking me out?\nYOU FOOL!"},
								{blip: snd_blip_generic, speaker: noone, can_skip: true, text: "So what if I'm only dealing 1 damage?"},
								{blip: snd_blip_generic, speaker: noone, can_skip: true, text: "DAMAGE IS DAMAGE!\nI just need to hit you... FIFTY TIMES!"}
							]));
					} else {
						return undefined;
					}
				},
				enemy_turn: function(player_actions) {
					var last_action = player_actions[array_length(player_actions) - 1];
					
					if (attack_mod_turns_remaining > 0 && --attack_mod_turns_remaining == 0) {
						enemies[0].attack = 18;
					}
					
					if (defense_mod_turns_remaining > 0 && --defense_mod_turns_remaining == 0) {
						enemies[0].defense = 10;
					}
					
					var scene;
					var transformed_this_turn = false;
					var win_type = undefined;
					
					if (enemies[0].state == enemy_states.knocked_down) {
						if (seen_dialogue.knocked_down) {
							scene = cutscene_init()
									.add(new ev_bubble(enemies[0].instance.x + 44, enemies[0].instance.y - 67, directions.left, 21, 4, [
											{blip: snd_blip_generic, speaker: noone, can_skip: true, text: "Go on... show me MERCY, already!"}
									]));
						} else {
							scene = cutscene_init()
								.add(new ev_script(function() {
									audio_sound_gain(global.encounter.music, 0, 500);
								}))
								.add({step: function() {
									return global.encounter.enemies[0].instance.y < 230;
								}})
								.add(new ev_bubble(enemies[0].instance.x + 44, enemies[0].instance.y - 37, directions.left, 21, 4, [
										{blip: snd_blip_generic, speaker: noone, can_skip: true, text: "Well! I see you overcame my DARK SIDE..."},
										{blip: snd_blip_generic, speaker: noone, can_skip: true, text: "And clawed VICTORY from my non-existent ARMS!"},
										{blip: snd_blip_generic, speaker: noone, can_skip: true, text: "Now you are ready for what's to come...\nI am truly a GREAT MENTOR!"},
										{blip: snd_blip_generic, speaker: noone, can_skip: true, text: "Now go, show me MERCY, and let us end this fight."}
								]));
							
							seen_dialogue.knocked_down = true;
						}
					} else if (enemies[0].state == enemy_states.dead) {
						scene = cutscene_init()
							.add(new ev_script(function() {
								audio_sound_gain(global.encounter.music, 0, 500);
							}))
							.add({step: function() {
								return global.encounter.enemies[0].instance.y < 230;
							}})
							.add(new ev_timer(30))
							.add(new ev_bubble(enemies[0].instance.x + 44, enemies[0].instance.y - (seen_dialogue.knocked_down ? 67 : 37), directions.left, 21, 4, [
								{blip: snd_blip_generic, speaker: noone, can_skip: false, text: "{d,2}{e,s,1/10}What... have you done?"},
								{blip: snd_blip_generic, speaker: noone, can_skip: false, text: "{d,2}{e,s,1/10}Striking when I am down... what kind of bravery is that?"},
								{blip: snd_blip_generic, speaker: noone, can_skip: false, text: "{d,2}{e,s,1/10}Ha ha... if you think this will give you the strength you need..."},
								{blip: snd_blip_generic, speaker: noone, can_skip: false, text: "{d,2}{e,s,1/10}... then you truly are a fool."}
							]))
							.add(new ev_script(function() {
								var enemy = global.encounter.enemies[0];
								vaporize(enemy.instance.x, enemy.instance.y, spr_enemy_dummonstrous_hurt);
								instance_destroy(enemy.instance);
							}));
							
						win_type = win_types.after_cutscene;
					} else if (transformed) {
						scene = undefined;
					} else {
						scene = cutscene_init();
						if (enemies[0].current_health <= enemies[0].max_health * 2 / 3) {
							scene
								.add(new ev_script(function() {
									audio_sound_gain(global.encounter.music, 0, 500);
								}))
								.add(new ev_bubble(enemies[0].instance.x + 44, enemies[0].instance.y - 67, directions.left, 21, 4, [
									{blip: snd_blip_generic, speaker: noone, can_skip: true, text: "HA! Think you have me on the ropes?\nYOU FOOL!"},
									{blip: snd_blip_generic, speaker: noone, can_skip: true, text: "This was merely my easier, FIRST PHASE!"},
									{blip: snd_blip_generic, speaker: noone, can_skip: true, text: "Now you have awakened my stoic DARK SIDE..."},
									{blip: snd_blip_generic, speaker: noone, can_skip: true, text: "I shall speak NO MORE... but my attacks will speak VOLUMES of your DOOM!"},
									{blip: snd_blip_generic, speaker: noone, can_skip: false, text: "{d,4}GRRAAAAAAAH!!!"}
								]))
								.add(new ev_sound(snd_dummonstrous_transform))
								.add(new ev_fade(fade_types.out, 129, c_red))
								.add(new ev_timer(69), [-2])
								.add(new ev_move(enemies[0].instance, enemies[0].instance.x, 200, 0.5))
								.add(new ev_script(function() {
									var enemy = global.encounter.enemies[0];
									enemy.attack = 18;
									enemy.defense = 10;
									enemy.description = ["Stronger, silent type that hates noise.", "Stay quiet to lower its guard."];
									enemy.instance.sprite_index = spr_enemy_dummonstrous_hurt;  // Usually not displayed
									enemy.instance.center_y = enemy.instance.y - enemy.instance.sprite_height div 2;
									enemy.instance.damage_bar_y = enemy.instance.bbox_top - 20;
									enemy.instance.alarm[0] = irandom_range(5, 30);
									
									global.encounter.health_after_transforming = enemy.current_health;
									global.encounter.transformed = true;
								}))
								.add({initialize: function() {
									instance_create_layer(0, 0, "system", obj_black);
								}})
								.add(new ev_fade(fade_types.in, 30, c_red))
								.add(new ev_timer(30))
								.add(new ev_destroyinst(obj_black))
								.add(new ev_fade(fade_types.in, 30, c_black))
								.add(new ev_script(function() {
									audio_stop_sound(global.encounter.music);
									global.encounter.music = audio_play_sound(mus_dummonstrous, 1, true);
								}), [-2]);
							
							transformed_this_turn = true;
						} else {
							var unique_lines = [];
							switch (last_action.type) {
								case player_action_types.play:
									switch (last_action.play.name) {
										case "Strike":
											if (!last_action.miss && !seen_dialogue.strike) {
												array_push(unique_lines, "Going for a simple attack? YOU FOOL!");
												array_push(unique_lines, "So what if you're saving BP with your no-cost strike?");
												array_push(unique_lines, "Now behold MY better, faster, STRONGER ATTACKS!");
												seen_dialogue.strike = true;
											}
											
											break;
										
										case "Roundhouse Kick":
											if (!last_action.miss && !seen_dialogue.roundhouse_kick) {
												array_push(unique_lines, "Failed to get a free attack in?! YOU FOOL!");
												array_push(unique_lines, "No way will you time your inputs perfectly to land a critical hit and a free turn!");
												array_push(unique_lines, "Now, suffer for your arrogance!!!");
												seen_dialogue.roundhouse_kick = true;
											}
											
											break;
										
										case "Deep Breath":
											if (!seen_dialogue.deep_breath) {
												array_push(unique_lines, "Recovering your energy? YOU FOOL!");
												array_push(unique_lines, "So what if managing your BP is important for flexibility in combat?");
												array_push(unique_lines, "I, on the other hand, will ATTACK RELENTLESSLY!");
												seen_dialogue.deep_breath = true;
											}
											
											break;
									}
									
									break;
								
								case player_action_types.act:
									if (last_action.act.name == "Talk") {
										if (!seen_dialogue.talk) {
											array_push(unique_lines, "Think you can win without actually fighting? YOU FOOL!");
											array_push(unique_lines, "Talking will do NOTHING for you! You have now WASTED your turn!");
											array_push(unique_lines, "Monsters in this era aren't pushovers!");
											array_push(unique_lines, "Now I am one step ahead... I will defeat you SOON!");
											seen_dialogue.talk = true;
										}
									} else if (!seen_dialogue.cover_mouth) {
										array_push(unique_lines, "Shutting your mouth? GOOD!");
										array_push(unique_lines, "Finally, some peace and quiet around here!");
										array_push(unique_lines, "I may be tempted to lower my DF to 0 in my harder second phase -");
										array_push(unique_lines, "- I mean, you heard NOTHING! Have at you!!!");
										seen_dialogue.cover_mouth = true;
									}
									
									break;
								
								case player_action_types.item:
									if (last_action.item == global.items.pancakes) {
										if (!seen_dialogue.pancakes) {
											array_push(unique_lines, "YOU FOOL! So what if you restored your lost health?");
											array_push(unique_lines, "Now you have no healing left! I hold the advantage now!!!");
											seen_dialogue.pancakes = true;
										}
									} else if (!seen_dialogue.hot_cocoa) {
										array_push(unique_lines, "YOU FOOL! So what if you restored your energy for attacks?");
										array_push(unique_lines, "Now you will only gain BP from grazing my bullets and risking damage!");
										array_push(unique_lines, "Victory is already mine!!!");
										seen_dialogue.hot_cocoa = true;
									}
									
									break;
								
								case player_action_types.spare:
									if (!seen_dialogue.spare) {
										array_push(unique_lines, "Mercy? YOU FOOL!");
										array_push(unique_lines, "In this era, fighting is in our hearts and SOULs!");
										array_push(unique_lines, "Strike me down fairly, and THEN I may consider granting you MERCY!");
										seen_dialogue.spare = true;
									}
									
									break;
							}
							
							var unique_lines_length = array_length(unique_lines);
							if (unique_lines_length > 0) {
								for (var i = 0; i < unique_lines_length; i++) {
									unique_lines[i] = {blip: snd_blip_generic, speaker: noone, can_skip: true, text: unique_lines[i]};
								}
								
								scene.add(new ev_bubble(enemies[0].instance.x + 44, enemies[0].instance.y - 67, directions.left, 21, 4, unique_lines));
							} else {
								scene.add(new ev_bubble(enemies[0].instance.x + 44, enemies[0].instance.y - 67, directions.left, 21, 4, [
									{blip: snd_blip_generic, speaker: noone, can_skip: true, text: choose(
										"Fall to my round bullets of DOOM!",
										"Now, PERISH!",
										"Victory will be MINE!"
									)}
								]));
							}
						}
					}
					
					if (first_turn) {
						first_turn = false;
					}
					
					return {
						cutscene: scene,
						attack: enemies[0].state == enemy_states.alive ? {
							pattern: (
								(transformed || transformed_this_turn)
								? choose(obj_pattern_dummonstrous_aim, obj_pattern_dummonstrous_lines, obj_pattern_dummonstrous_bounce)
								: obj_pattern_dummonstrous_aim
							),
							box: {
								x1: 250,
								y1: 250,
								x2: 389,
								y2: 389
							},
							overlay: true
						} : undefined,
						win_type: win_type,
						death_text: transformed ? [
							"... with Riley's SOUL, Dummonstrous unleashed hell upon Earth.",
							"Now we are under the cotton-fisted rule of the great, terrible dummy..."
						] : [
							"... and thus, the human fell to the dummy.",
							"If only the human survived longer...",
							"That would've made a better story."
						]
					};
				},
				initialized: false,
				first_turn: true,
				seen_dialogue: {
					strike: false,
					roundhouse_kick: false,
					deep_breath: false,
					check: false,
					talk: false,
					cover_mouth: false,
					pancakes: false,
					hot_cocoa: false,
					knocked_down: false,
					spare: false
				},
				transformed: false,
				attack_mod_turns_remaining: 0,
				defense_mod_turns_remaining: 0
			};
		
		case encounters.anser_quigley:
			return {
				enemies: [
					{
						name: "Quigley",
						object: obj_enemy_quigley,
						_x: 165,
						_y: 230,
						max_health: 250,
						attack: 18,
						defense: 12,
						default_kill: true,
						spareable: true,
						invulnerable: false,
						description: [
							"Unquestionably in love with Anser.",
							"Nothing escapes his observation.\nEspecially spherical objects."
						],
						execution_points: 50,
						gold: 30
					},
					{
						name: "Anser",
						object: obj_enemy_anser,
						_x: 469,
						_y: 230,
						max_health: 250,
						attack: 18,
						defense: 8,
						default_kill: true,
						spareable: true,
						invulnerable: false,
						description: [
							"Answers to the Royal Guard.\nGuaranteed to bite! May bark.",
							"Her swordsfoxship skills are as stalwart as her ego."
						],
						execution_points: 50,
						gold: 30
					}
				],
				attacks: {
					intro_1: {
						pattern: obj_pattern_anser_quigley_intro_1,
						box: {x1: 224, y1: 281, x2: 416, y2: 358},
						overlay: false
					},
					intro_2: {
						pattern: obj_pattern_anser_quigley_intro_2,
						box: {x1: 275, y1: 184, x2: 364, y2: 389},
						overlay: true
					},
					intro_3: {
						pattern: obj_pattern_anser_quigley_intro_3,
						box: {x1: 215, y1: 265, x2: 424, y2: 374},
						overlay: true
					},
					intro_3_redux: {
						pattern: obj_pattern_anser_quigley_intro_3_redux,
						box: {x1: 215, y1: 265, x2: 424, y2: 374},
						overlay: true
					},
					ring: {
						pattern: obj_pattern_anser_quigley_ring,
						box: {x1: 224, y1: 197, x2: 416, y2: 389},
						overlay: true
					},
					starfall: {
						pattern: obj_pattern_anser_quigley_starfall,
						box: {x1: 230, y1: 210, x2: 409, y2: 389},
						overlay: true
					},
					big_stars: {
						pattern: obj_pattern_anser_quigley_big_stars,
						box: {x1: 250, y1: 250, x2: 389, y2: 389},
						overlay: true
					},
					caltrops: {
						pattern: obj_pattern_anser_quigley_caltrops,
						box: {x1: 250, y1: 250, x2: 389, y2: 389},
						overlay: true
					},
					quigley_solo_1: {
						pattern: obj_pattern_quigley_solo_1,
						box: {x1: 254, y1: 257, x2: 385, y2: 382},
						overlay: true
					},
					quigley_solo_2: {
						pattern: obj_pattern_quigley_solo_2,
						box: {x1: 224, y1: 197, x2: 416, y2: 389},
						overlay: true
					},
					anser_solo: {
						pattern: obj_pattern_anser_solo,
						box: {x1: 250, y1: 250, x2: 389, y2: 389},
						overlay: true
					},
					quigley_revenge: {
						pattern: obj_pattern_quigley_revenge,
						box: {x1: 262, y1: 287, x2: 377, y2: 352},
						overlay: false
					},
					anser_revenge: {
						pattern: obj_pattern_anser_revenge,
						box: {x1: 293, y1: 293, x2: 347, y2: 347},
						overlay: true
					}
				},
				player_turn: function() {
					if (!initialized) {
						instance_create_layer(320, 0, "system", obj_bg_quigley_anser);
						music = audio_play_sound(mus_anser_quigley_battle, 50, true);
						initialized = true;
					}
					
					var flavor_text;
					if (turns_passed == 0) {
						flavor_text = "Quigley and Anser guard the forest perimeter!";
					} else if (enemies[0].state == enemy_states.dead) {
						if (enemies[1].state == enemy_states.knocked_down) {
							flavor_text = "Anser has nothing left to give.";
						} else {
							flavor_text = choose(
								"Anser glares at you with malice in her eyes.",
								"Anser bares her teeth."
							);
						}
					} else if (enemies[1].state == enemy_states.dead) {
						if (enemies[0].state == enemy_states.knocked_down) {
							flavor_text = "Quigley is waiting for you to kill him.";
						} else {
							flavor_text = choose(
								"Quigley blinks nervously.",
								"Quigley growls at you."
							);
						}
					} else if (
						(enemies[0].state == enemy_states.knocked_down || enemies[0].state == enemy_states.spared)
						&& (enemies[1].state == enemy_states.knocked_down || enemies[1].state == enemy_states.spared)
					) {
						flavor_text = "Quigley and Anser have no fight left in them.";
					} else if (enemies[0].state == enemy_states.knocked_down || enemies[0].state == enemy_states.spared) {
						// Use any standard line without mention of Quigley
						flavor_text = choose(
							"Anser stares you down... or at least she's squinting very hard at you.",
							"Anser flashes her sword.",
							"Anser cuts a snowflake in half.\nShe looks proud of herself."
						);
					} else if (enemies[1].state == enemy_states.knocked_down || enemies[1].state == enemy_states.spared) {
						// Use any standard line without mention of Anser
						flavor_text = choose(
							"Quigley sifts through a bag of doohickies and whatchamacallits.",
							"Quigley wipes fog off of his glasses.",
							"Quigley eyes a snowball playfully.",
							"Quigley drops his binoculars into a snowpile and plays it off as intentional."
						);
					} else if (starfall_last_turn && !seen_dialogue.starfall_flavor) {
						flavor_text = "Anser raises an eyebrow at Quigley and mouths \"why?\".";
						seen_dialogue.starfall_flavor = true;
					} else {
						flavor_text = choose(
							"Quigley sifts through a bag of doohickies and whatchamacallits.",
							"Quigley wipes fog off of his glasses.",
							"Quigley eyes a snowball playfully.",
							"Quigley drops his binoculars into a snowpile and plays it off as intentional.",
							"Anser stares you down... or at least she's squinting very hard at you.",
							"Anser flashes her sword.",
							"Anser cuts a snowflake in half.\nShe looks proud of herself.",
							"Anser winks at Quigley.\nHe winks back.\n... this repeats for a while.",
							"Quigley and Anser bark in unison.",
							"Quigley hands Anser a dog bowl filled with water to cool off.",
							"Anser tosses Quigley a peppermint shaped like a heart."
						);
					}
					
					var acts = [
						enemies[0].state == enemy_states.alive ? [
							{
								name: "Pet",
								cutscene: cutscene_init()
									.add(new ev_dialogue_battle([
										"You reach your hand out to pet Quigley.",
										"He slyly backs out of petting range."
									]))
							},
							{
								name: "Question",
								cutscene: cutscene_init()
									.add(new ev_dialogue_battle(
										enemies[1].state == enemy_states.dead
										? [
											["You ask Quigley about the history of New Home.\n... he ignores you."],
											["You ask Quigley if dogs can pet other dogs.\n... he ignores you."],
											["You ask Quigley about SOULs.\n... he ignores you."]
										][quigley_questions[0]]
										: [
											[
												"You ask Quigley about the history of New Home.",
												"He excitedly takes out a large book from his bag."
											],
											["You ask Quigley if dogs can pet other dogs.\nHis eyes widen."],
											["You ask Quigley about SOULs.\n... most of what he says goes in one ear and out the other."]
										][quigley_questions[0]]
									))
							},
							{
								name: "Snowball",
								cutscene: cutscene_init()
									.add(new ev_dialogue_battle(
										enemies[1].state == enemy_states.alive
										? [
											"You throw a snowball near Quigley.",
											"His eyes grow wide as he runs towards it.",
											"Quigley's DF drops to 0!"
										]
										: ["You throw a snowball near Quigley.\n... he doesn't even flinch."]
									))
							}
						] : [],
						enemies[1].state == enemy_states.alive ? [
							{
								name: "Boop",
								cutscene: cutscene_init()
									.add(new ev_dialogue_battle([
										"You try to boop Anser on the nose.",
										enemies[0].state == enemy_states.alive
										? "She awkwardly pushes your hand away in response."
										: "She smacks your hand away with the broad side of her sword."
									]))
							},
							{
								name: "Taunt",
								cutscene: cutscene_init()
									.add(new ev_dialogue_battle(["You question Anser's fighting ability.\nShe scowls at you."]))
							},
							{
								name: "Admire",
								cutscene: cutscene_init()
									.add(new ev_dialogue_battle(
										enemies[1].state == enemy_states.alive
										? [
											"You tell Anser her swordsmanship is elegant and impressive.",
											"Anser's AT is lowered!"
										]
										: ["You tell Anser her swordsmanship is elegant and impressive."]
									))
							}
						] : []
					];
					
					if (enemies[0].state == enemy_states.alive && enemies[1].state == enemy_states.alive) {
						acts[0][2].cutscene.add({initialize: function() {
							global.encounter.enemies[0].defense = 0;
							global.encounter.quigley_debuff = 2;
						}});
						
						acts[1][2].cutscene.add({initialize: function() {
							global.encounter.enemies[1].attack = 14;
							global.encounter.anser_debuff = 2;
						}});
					}
					
					return {
						flavor_text: flavor_text,
						acts: acts,
						win_check: {
							spared: false,
							dead: false
						},
						can_flee: false
					};
				},
				enemy_turn: function(player_actions) {
					var player_actions_length = array_length(player_actions);
					var last_action = player_actions[player_actions_length - 1];
					
					if (quigley_debuff > 0 && --quigley_debuff == 0) {
						enemies[0].defense = 12;
					}
					
					if (anser_debuff > 0 && --anser_debuff == 0) {
						enemies[1].attack = 18;
					}
					
					var attack = undefined;
					starfall_last_turn = false;
					
					if (enemies[0].state != enemy_states.alive && enemies[1].state == enemy_states.alive) {
						attack = attacks.anser_solo;
					} else if (enemies[1].state != enemy_states.alive && enemies[0].state == enemy_states.alive) {
						attack = [attacks.quigley_solo_1, attacks.quigley_solo_2][quigley_solo_attack];
						quigley_solo_attack = !quigley_solo_attack;
					} else if (enemies[0].state == enemy_states.alive && enemies[1].state == enemy_states.alive) {
						if (turns_passed == 0) {
							attack = attacks.intro_1;
						} else if (turns_passed == 1) {
							attack = attacks.intro_2;
						} else if (turns_passed == 2) {
							attack = attacks.intro_3;
						} else {
							attack = [
								attacks.intro_3_redux,
								attacks.ring,
								attacks.starfall,
								attacks.big_stars,
								attacks.caltrops
							][general_rotation_attacks[0]];
							
							array_shift(general_rotation_attacks);
							if (array_length(general_rotation_attacks) == 0) {
								general_rotation_attacks = array_shuffle([0, 1, 2, 3, 4]);
							}
							
							if (attack == attacks.starfall) {
								starfall_last_turn = true;
							}
						}
					}
					
					// All the code related to dialogue in this encounter is horrible, hard to follow, and probably has some logic errors somewhere.
					// I am sorry for this.
					var dialogue = undefined;
					if (last_action.type == player_action_types.act) {
						switch (last_action.act.name) {
							case "Pet":
								if (enemies[1].state == enemy_states.dead) {
									dialogue = [
										{enemy: "Quigley", head: 13, text: "... no. Not after what you did."}
									];
								} else {
									dialogue = [
										{enemy: "Quigley", head: 7, text: "Scandalous! What kind of dog do you think I am?!"},
										{enemy: "Quigley", head: 8, text: "I have some self-respect, you know."}
									];
									
									if (enemies[1].state == enemy_states.alive) {
										array_push(dialogue, {enemy: "Anser", head: 4, text: "... and where was that self-respect ten minutes ago?"});
									}
								}
								
								break;
							
							case "Question":
								if (enemies[1].state != enemy_states.dead) {
									switch (quigley_questions[0]) {
										case 0:
											dialogue = [
												{enemy: "Quigley", head: 4, text: "Oh, that's a good one! Well, the most important thing..."},
												{enemy: "Anser", head: 2, text: "Quigley?"},
												{enemy: "Quigley", text: "...which is when Asgore decided to reroute the..."},
												{enemy: "Anser", head: 4, text: "Quigley!"},
												{enemy: "Quigley", text: "Which naturally meant that obsidian became..."},
												{enemy: "Anser", head: 1, text: "Good grief..."}
											];
											
											if (enemies[1].state != enemy_states.alive) {
												array_delete(dialogue, 1, 1);
												array_delete(dialogue, 3, 1);
												array_delete(dialogue, 5, 1);
											}
											
											break;
										
										case 1:
											dialogue = [{enemy: "Quigley", head: 10, text: "Dogs petting other dogs? Preposterous! Unless...?"}];
											if (enemies[1].state == enemy_states.alive) {
												array_push(dialogue, {enemy: "Anser", head: 4, text: "Well, I wouldn't be against it..."});
											}
											
											break;
										
										case 2:
											dialogue = [
												{enemy: "Quigley", text: "Well, everyone knows in the beginning, there was magic..."},
												{enemy: "Quigley", text: "... and, of course, the shattering..."},
												{enemy: "Quigley", text: "... creation of two races..."},
												{enemy: "Quigley", text: "... the Angel's heaven..."},
												{enemy: "Quigley", head: 1, text: "But that part's mostly speculation!"}
											];
											
											if (enemies[1].state == enemy_states.alive) {
												array_push(dialogue, {enemy: "Anser", head: 2, text: "All that matters... is that {e,w}your{e,n} SOUL can help free us."});
											}
											
											break;
									}
								}
								
								// If all three questions have been asked, reset the bag
								array_shift(quigley_questions);
								if (array_length(quigley_questions) == 0) {
									quigley_questions = array_shuffle([0, 1, 2]);
								}
								
								break;
							
							case "Snowball":
								if (enemies[1].state == enemy_states.alive) {
									dialogue = [
										{enemy: "Quigley", head: 4, text: "Oh, fetch! This one is a classic. Lemme at it!"},
										{enemy: "Anser", head: 7, text: "This is not the time, Quigley!"}
									];
								} else {
									dialogue = [{enemy: "Quigley", head: 7, text: "No! No more distractions."}];
								}
								
								break;
							
							case "Boop":
								if (enemies[0].state != enemy_states.dead && !seen_dialogue.anser_boop) {
									dialogue = [{enemy: "Anser", head: 5, text: "Don't! That's embarrassing!!"}];
									if (enemies[0].state == enemy_states.alive) {
										array_push(dialogue, {enemy: "Quigley", head: 1, text: "(Do it again! That was adorable...)"});
									}
									
									seen_dialogue.anser_boop = true;
								}
								
								break;
							
							case "Taunt":
								if (enemies[0].state == enemy_states.alive) {
									dialogue = [{enemy: "Anser", head: 6, text: "Your unfounded insults mean nothing to me, human!"}];
								} else {
									dialogue = [{enemy: "Anser", head: 6, text: "Don't get cocky and think you've won, human."}];
								}
								
								break;
							
							case "Admire":
								if (enemies[0].state == enemy_states.alive) {
									dialogue = [{enemy: "Anser", head: 8, text: "Oh? Well, I have years of experience! Here, watch more closely and learn."}];
								} else {
									dialogue = [{enemy: "Anser", head: 10, text: "Flattery won't get you anywhere."}];
								}
								
								break;
						}
					} else if (enemies[0].state == enemy_states.dead) {
						if (enemies[1].state == enemy_states.alive) {
							// Setting the head here is needed to have it be correct the first time one of these lines appears.
							dialogue = [{enemy: "Anser", head: 13, text: choose(
								"May the forest claim you and leave nothing but bones!",
								"Quigley...?",
								"I'll cut a hole in your SOUL!"
							)}];
						} else if (enemies[1].state == enemy_states.knocked_down) {
							if (anser_second_wind && !seen_dialogue.anser_knocked_down_second_wind) {
								dialogue = [
									{enemy: "Anser", text: "So that's it... we failed..."},
									{enemy: "Anser", text: "I pray that Asgore gives you a slow death."}
								];
								
								enemies[1].spareable = false;
								seen_dialogue.anser_knocked_down_second_wind = true;
							} else {
								var killed_quigley_this_turn = false;
								for (var i = 0; i < player_actions_length; i++) {
									if (
										player_actions[i].type == player_action_types.play
										&& player_actions[i].target == 0
										&& player_actions[i].play.type == play_types.attack
										&& !player_actions[i].miss
									) {
										killed_quigley_this_turn = true;
										break;
									}
								}
								
								if (killed_quigley_this_turn) {
									dialogue = [
										{enemy: "Anser", head: 13, text: "No... no, how could you?"},
										{enemy: "Anser", text: "I won't rest until you're {e,s}dead{e,n}!"}
									];
								} else {
									dialogue = [{enemy: "Anser", text: (
										last_action.type == player_action_types.spare
										? "Like I'd accept your MERCY now."
										: "..."
									)}];
								}
							}
						}
					} else if (enemies[1].state == enemy_states.dead && enemies[0].state == enemy_states.alive) {
						// Same as above.
						dialogue = [{enemy: "Quigley", head: 9, text: choose(
							"A-Anser...? No...",
							"I thought you were different...",
							"But... we were supposed to..."
						)}];
					} else if (enemies[1].state == enemy_states.dead && enemies[0].state == enemy_states.knocked_down) {
						var made_spareable = false;
						if (last_action.type == player_action_types.spare) {
							dialogue = [{enemy: "Quigley", text: [
								"Don't... patronize me... just end me.",
								"...",
								"... why?"
							][quigley_spare_count++]}];
							
							// The fourth spare attempt works.
							if (quigley_spare_count == 3) {
								enemies[0].spareable = true;
								made_spareable = true;
							}
						} else if (seen_dialogue.quigley_knocked_down) {
							dialogue = [{enemy: "Quigley", text: "... just do it, already."}];
						}
						
						if (!made_spareable) {
							enemies[0].spareable = false;
						}
					} else if ((enemies[0].state == enemy_states.knocked_down || enemies[0].state == enemy_states.spared) && enemies[1].state == enemy_states.alive) {
						dialogue = [{enemy: "Anser", text: choose(
							"One on one, huh? Now the fight's fair!",
							"I'll be fine, Quigley. You know what I can do ~",
							"Surrender before I really up the bark and bite!",
							"You're not stepping foot into the forest!"
						)}];
					} else if ((enemies[1].state == enemy_states.knocked_down || enemies[1].state == enemy_states.spared) && enemies[0].state == enemy_states.alive) {
						dialogue = [{enemy: "Quigley", text: choose(
							"Don't worry, dear! I can stop them.",
							"I can still capture you... I think...",
							"You can still surrender, you know!",
							"I'll just have to work twice as hard now."
						)}];
					} else if (enemies[0].state == enemy_states.alive && enemies[1].state == enemy_states.alive) {
						var quigley_half_health = enemies[0].current_health <= enemies[0].max_health / 2;
						var quigley_quarter_health = enemies[0].current_health <= enemies[0].max_health / 4;
						var anser_half_health = enemies[1].current_health <= enemies[1].max_health / 2;
						var anser_quarter_health = enemies[1].current_health <= enemies[1].max_health / 4;
						
						// If these lines were included in Anser's standard pool, there would be a 1/7 chance of
						// picking either of them. We have to separate it out to allow Quigley to respond.
						if (!quigley_half_health && !anser_half_health && irandom_range(1, 7) == 1) {
							dialogue = choose(
								[
									{enemy: "Anser", text: "You fight like a squirrel!"},
									{enemy: "Quigley", text: "Like Carl? He is a champion, to be fair..."}
								],
								[
									{enemy: "Quigley", text: "Riley is two metres away from us!"},
									{enemy: "Anser", text: "... are you sure you need your binoculars to determine that?"}
								]
							);
						} else {
							dialogue = [
								anser_quarter_health && !seen_dialogue.anser_quarter_health
								? {enemy: "Anser", head: 6, text: "Ugh... this isn't over yet!"}
								: (
									anser_half_health && !seen_dialogue.anser_half_health
									? {enemy: "Anser", head: 6, text: "You're quite the fighter, Riley... but the Royal Guard never yields!"}
									: {enemy: "Anser", text:
										anser_half_health ? choose(
											"I won't fail Snowdown!",
											"The Royal Guard won't waver, human.",
											"This is why I've trained so hard. To defend the Underground.",
											"You won't get past me!",
											"I hardly even felt that.",
											"For the defense of Snowdown!"
										) : choose(
											"Bringing fists to a sword fight, eh?",
											"You'll be seeing stars soon!",
											"You're not so bad at this, human.",
											"En garde!",
											"I won't go easy on you, human. Stay on your feet!",
											"Try to keep your eyes on my blade!",
											"Do all humans have clumsy footwork?",
											"The sword is more graceful than the pen!",
											"I'll cut you down swiftly!",
											"Ha! Don't lose your footing.",
											"This is good fencing practice.",
											"Keep them on their toes, Quigley!"
										)
									}
								),
								quigley_quarter_health && !seen_dialogue.quigley_quarter_health
								? {enemy: "Quigley", head: 14, text: "I'm exhausted... can I call for a time out?"}
								: (
									quigley_half_health && !seen_dialogue.quigley_half_health
									? {enemy: "Quigley", head: 3, text: "I don't think I'm supposed to be the one seeing stars..."}
									: {enemy: "Quigley", text:
										quigley_half_health ? choose(
											"I must go on... for Snowdown!",
											"(Keep it together, Quigley.)",
											"My duty is to protect Snowdown!",
											"You'll go no further, Riley!",
											"We won't relent.",
											"Snowdown is counting on us!"
										) : choose(
											"One moment... locking on...",
											"Here, Anser, this'll help!",
											"I'm sorry if this hurts.",
											"I've got this doohickey set!",
											"I said we're just doing our job, right?",
											"It's a good thing it's \"Bring your bear traps to work!\" day.",
											"I know all there is to know about humans! ... where's your third arm?",
											"There's no trick this young, good-looking dog can't be taught.",
											"I've got my eyes on you!",
											"Ready... aim...",
											"I've got more where that came from!"
										)
									}
								)
							];
							
							if (quigley_half_health) seen_dialogue.quigley_half_health = true;
							if (quigley_quarter_health) seen_dialogue.quigley_quarter_health = true;
							if (anser_half_health) seen_dialogue.anser_half_health = true;
							if (anser_quarter_health) seen_dialogue.anser_quarter_health = true;
						}
					}
					
					if (enemies[0].state == enemy_states.knocked_down && !seen_dialogue.quigley_knocked_down) {
						if (is_undefined(dialogue)) {
							dialogue = [{enemy: "Quigley", text: "Sorry, Anser... I gave it my best."}];
						} else {
							array_insert(dialogue, 0, {enemy: "Quigley", text: "Sorry, Anser... I gave it my best."});
						}
						
						seen_dialogue.quigley_knocked_down = true;
						enemies[1].defense = 0;
					} else if (enemies[1].state == enemy_states.knocked_down && !seen_dialogue.anser_knocked_down) {
						// If Quigley is dead, disregard the existing dialogue ("..." from Anser, which should only play on turns after this line does)
						if (is_undefined(dialogue) || enemies[0].state == enemy_states.dead) {
							dialogue = [{enemy: "Anser", text: (
								enemies[0].state == enemy_states.dead
								? "N-No... I can't fail... not now..."
								: "You're tough, human... I don't think I can go on."
							)}];
						} else {
							array_insert(dialogue, 0, {enemy: "Anser", text: "You're tough, human... I don't think I can go on."});
						}
						
						seen_dialogue.anser_knocked_down = true;
						enemies[0].defense = 0;
					}
					
					var cutscene = cutscene_init();
					
					var quigley_head;
					if (enemies[1].state == enemy_states.dead) {
						quigley_head = 9;  // Sad head
					} else if (enemies[0].current_health <= enemies[0].max_health / 4) {
						quigley_head = 15;  // Low HP head
					} else {
						quigley_head = 0;  // Normal head
					}
					
					var anser_head;
					if (enemies[0].state == enemy_states.dead) {
						anser_head = 13;  // Enraged head
					} else if (enemies[1].current_health <= enemies[1].max_health / 4) {
						anser_head = 14;  // Low HP / exhausted head (there was no "Low HP" head provided in the original spritesheet, so I just picked the one that looked best to me)
					} else {
						anser_head = 3;  // Normal head
					}
					
					cutscene.add(new ev_set(obj_enemy_quigley, "head", quigley_head));
					cutscene.add(new ev_set(obj_enemy_anser, "head", anser_head));
					
					if (!is_undefined(dialogue)) {
						// A simplified dialogue format is used for this encounter to make the code more readable.
						// It was easiest to have each line of dialogue use a separate event - it's not the "best" way to
						// do cutscenes, but intelligently combining lines while taking head changes into account would've
						// been a complete waste of time.
						// Here, we're just expanding the simplified format into proper cutscene events.
						var dialogue_length = array_length(dialogue);
						for (var i = 0; i < dialogue_length; i++) {
							if (dialogue[i].enemy == "Quigley") {
								if (variable_struct_exists(dialogue[i], "head")) {
									cutscene.add(new ev_set(obj_enemy_quigley, "head", dialogue[i].head));
								}
								
								cutscene.add(new ev_bubble(enemies[0].instance.x + 64, enemies[0].instance.y - 109, directions.left, 21, 4, [
									{blip: snd_blip_quigley, speaker: noone, can_skip: true, text: dialogue[i].text}
								]));
								
								if (variable_struct_exists(dialogue[i], "head")) {
									cutscene.add(new ev_set(obj_enemy_quigley, "head", quigley_head));
								}
							} else {
								if (variable_struct_exists(dialogue[i], "head")) {
									cutscene.add(new ev_set(obj_enemy_anser, "head", dialogue[i].head));
								}
								
								cutscene.add(new ev_bubble(enemies[1].instance.x - 85, enemies[1].instance.y - 133, directions.right, 21, 4, [
									{blip: snd_blip_anser, speaker: obj_enemy_anser.id, can_skip: true, text: dialogue[i].text}
								]));
								
								if (variable_struct_exists(dialogue[i], "head")) {
									cutscene.add(new ev_set(obj_enemy_anser, "head", anser_head));
								}
							}
						}
					}
					
					if (!music_stopped && (
						enemies[0].state == enemy_states.dead && enemies[1].state == enemy_states.knocked_down
						|| enemies[0].state == enemy_states.knocked_down && enemies[1].state == enemy_states.dead
					)) {
						// Anser is never spareable if Quigley is dead, whereas Quigley can be spared with some persistence.
						enemies[enemies[0].state == enemy_states.dead].spareable = false;
						
						audio_sound_gain(music, 0, 500);
						music_stopped = true;
					}
					
					if (last_action.type == player_action_types.play && last_action.play.type == play_types.attack && !last_action.miss) {
						if (enemies[0].state == enemy_states.dead && last_action.target == 0) {
							if (enemies[1].state == enemy_states.knocked_down) {
								// Anser gets back up if you kill Quigley while she's knocked down.
								cutscene
									.add(new ev_shake(enemies[1].instance, 4))
									.add({initialize: function() {
										global.encounter.enemies[1].state = enemy_states.alive;
										global.encounter.enemies[1].current_health = global.encounter.enemies[1].max_health div 2;
									}}, [-2])
									.add(new ev_sound(snd_flicker), [-3])
									.add({initialize: function() {
										global.encounter.music = audio_play_sound(mus_anser_quigley_battle, 50, true);
										audio_sound_pitch(global.encounter.music, 0.9);
										global.encounter.music_stopped = false;
									}});
						
								// The attack should still be set to undefined here, so now that Anser's back up she needs to do her solo attack.
								attack = attacks.anser_solo;
								anser_second_wind = true;
							} else if (enemies[1].state == enemy_states.spared) {
								cutscene
									.add({initialize: function() {
										audio_sound_gain(global.encounter.music, 0, 500);
									}})
									.add(new ev_timer(30))
									.add(new ev_lerp_var(obj_enemy_anser, "image_alpha", 1, 0, 0.2))
									.add(new ev_sound(snd_flee), [-2])
									.add(new ev_timer(60))
									.add(new ev_bubble(633, enemies[1].instance.y - 133, directions.right, 21, 4, [
										{blip: snd_blip_anser, speaker: noone, can_skip: false, text: "{d,3}{e,s}You heinous bastard!"}
									]));
						
								attack = attacks.anser_revenge;
							}
						} else if (enemies[1].state == enemy_states.dead && enemies[0].state == enemy_states.spared && last_action.target == 1) {
							cutscene
								.add({initialize: function() {
									audio_sound_gain(global.encounter.music, 0, 500);
								}})
								.add(new ev_timer(30))
								.add(new ev_set(enemies[0].instance, "revenge", true))
								.add({initialize: function() {
									instance_create_layer(
										global.encounter.enemies[0].instance.x + 28,
										global.encounter.enemies[0].instance.y - 42,
										"top",
										obj_enemy_quigley_binoculars_bounce
									);
								}})
								.add(new ev_sound(snd_flicker))
								.add(new ev_shake(enemies[0].instance, 4))
								.add(new ev_timer(60))
								.add(new ev_bubble(enemies[0].instance.x + 64, enemies[0].instance.y - 109, directions.left, 21, 4, [
									{blip: snd_blip_quigley, speaker: noone, can_skip: false, text: "{d,3}After I stuck up for you..."},
									{blip: snd_blip_quigley, speaker: noone, can_skip: false, text: "{d,3}Humans really {e,s}are{e,n} all the same."},
									{blip: snd_blip_quigley, speaker: noone, can_skip: false, text: "{d,3}..."},
									{blip: snd_blip_quigley, speaker: noone, can_skip: false, text: "{d,3}I'm not sorry for this."}
								]))
								.add({
									initialize: function() {
										instance = global.encounter.enemies[0].instance;
										start = instance.x;
										progress = 0;
									},
									step: function() {
										progress += 0.04;
										instance.x = lerp(start, 320, 1 - power(1 - progress, 3));
										return (instance.x != 320);
									}
								})
								.add(new ev_timer(15))
								.add(new ev_set(enemies[0].instance, "revenge_image", 1))
								.add(new ev_sound(snd_flicker))
								.add(new ev_shake(enemies[0].instance, 4))
								.add(new ev_timer(30))
								.add(new ev_set(enemies[0].instance, "revenge_image", 2))
								.add(new ev_timer(15))
								.add(new ev_set(enemies[0].instance, "revenge_image", 3))
								.add(new ev_timer(45))
								.add(new ev_set(enemies[0].instance, "revenge_image", 4))
								.add(new ev_sound(snd_whoosh))
								.add({
									initialize: function() {
										trap = instance_create_layer(
											global.encounter.enemies[0].instance.x + 6,
											global.encounter.enemies[0].instance.y - 110,
											"top",
											obj_enemy_quigley_trap
										);
									},
									step: function() {
										return instance_exists(trap);
									}
								})
								.add(new ev_timer(15));
					
							attack = attacks.quigley_revenge;
						}
					}
					
					var win_type;
					if (is_undefined(attack) && (
						enemies[0].state == enemy_states.spared && enemies[1].state == enemy_states.spared
						|| enemies[0].state == enemy_states.dead && enemies[1].state == enemy_states.dead
					)) {
						win_type = win_types.immediate;
					} else {
						win_type = undefined;
					}
					
					turns_passed++;
					
					return {
						cutscene: cutscene,
						attack: attack,
						win_type: win_type,
						death_text: (
							enemies[0].state == enemy_states.dead
							? [
								"... and thus, Anser avenged her husband and brought Asgore the SOUL.",
								"She will forever remain a hero... alone in her success."
							]
							: (
								enemies[1].state == enemy_states.dead
								? [
									"... from there, Quigley brought us the human SOUL.",
									"However, it's clear he wasn't happy about it.",
									"For whatever reason he feels despair, only two come to mind..."
								]
								: [
									"... and so, the loving couple brought Asgore the SOUL.",
									"It seems we're one step closer to freedom.",
									"We have two talented Royal Guards to thank for that."
								]
							)	
						)
					};
				},
				initialized: false,
				turns_passed: 0,
				general_rotation_attacks: array_shuffle([0, 1, 2, 3, 4]),
				quigley_solo_attack: choose(0, 1),
				quigley_solo_2_side: choose(-1, 1),
				anser_solo_side: choose(-1, 1),
				seen_dialogue: {
					starfall_flavor: false,
					anser_boop: false,
					quigley_half_health: false,
					quigley_quarter_health: false,
					quigley_knocked_down: false,
					anser_half_health: false,
					anser_quarter_health: false,
					anser_knocked_down: false,
					anser_knocked_down_second_wind: false
				},
				starfall_last_turn: false,
				quigley_questions: array_shuffle([0, 1, 2]),
				quigley_debuff: 0,
				quigley_spare_count: 0,
				anser_debuff: 0,
				anser_second_wind: false,
				music_stopped: false
			};
	}
}