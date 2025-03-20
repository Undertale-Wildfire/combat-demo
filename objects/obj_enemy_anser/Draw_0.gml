if (enemy.state == enemy_states.knocked_down || enemy.state == enemy_states.dead) {
	draw_sprite(spr_enemy_anser_knocked_down, 0, x, y);
} else {
	if (enemy.state == enemy_states.spared) {
		draw_set_alpha(0.5 * image_alpha);  // image_alpha is used for Anser's betrayal kill cutscene
	}
	
	var hurt = (instance_exists(obj_damage_bar) && obj_damage_bar.enemy == enemy);
	if (hurt || enemy.state == enemy_states.spared) {
		bob_timer = 0.75;
		tail_timer = 0;
	} else {
		bob_timer += 0.01;
		if (bob_timer == 1) {
			bob_timer = 0;
		}
		
		tail_timer += 0.025;
		if (tail_timer == 1) {
			tail_timer = 0;
		}
	}
	
	draw_sprite_ext(spr_enemy_anser_tail, 0, x + 28, y - 60, 1, 1, dsin(tail_timer * 360) * 5, c_white, enemy.state == enemy_states.spared ? 0.5 * image_alpha : 1);
	
	var bob_amount = dsin(bob_timer * 360);
	draw_sprite_ext(spr_enemy_anser_legs, 0, x, y, 29/28 + bob_amount * 1/28, 29/30 - bob_amount * 1/30, 0, c_white, enemy.state == enemy_states.spared ? 0.5 * image_alpha : 1);
	draw_sprite_ext(spr_enemy_anser_sword, 0, x - 42, y - 79 + bob_amount * 3, 1, 1, -5 + bob_amount * -5, c_white, enemy.state == enemy_states.spared ? 0.5 * image_alpha : 1);
	draw_sprite(spr_enemy_anser_torso, 0, x - 14, y - 93 + bob_amount * 3);
	
	draw_sprite(
		/*
		Talking sprites (spr_enemy_anser_heads_talk, otherwise unused)
		These look weird to me. I'm leaving them out for now.
		
		enemy.state == enemy_states.spared ? spr_enemy_anser_head_spared : (
			(global.speaker != id && talk_counter % 8 < 4 || ++talk_counter % 8 < 4)
			? spr_enemy_anser_heads
			: spr_enemy_anser_heads_talk
		),
		*/
		hurt ? spr_enemy_anser_head_hurt : spr_enemy_anser_heads,
		(enemy.state == enemy_states.spared && global.encounter.enemies[0].state == enemy_states.dead) ? 13 : head,
		x - 46,
		y - 118 + bob_amount * 4
	);
	
	draw_sprite_ext(
		spr_enemy_anser_hands,
		enemy.state == enemy_states.spared
		? (global.encounter.enemies[0].state == enemy_states.dead ? 4 : 5)
		: (hurt ? 4 : hand),
		x + 46,
		y - 111 + bob_amount * 3,
		1,
		1,
		-5 + bob_amount * -5,
		c_white,
		enemy.state == enemy_states.spared ? 0.5 * image_alpha : 1
	);
	
	if (enemy.state == enemy_states.spared) {
		draw_set_alpha(1);
	}
}