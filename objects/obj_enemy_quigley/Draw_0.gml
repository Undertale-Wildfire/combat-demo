if (revenge) {
	draw_sprite(spr_enemy_quigley_revenge, revenge_image, x, y);
} else if (enemy.state == enemy_states.knocked_down || enemy.state == enemy_states.dead) {
	draw_sprite(spr_enemy_quigley_knocked_down, 0, x, y);
} else {
	if (enemy.state == enemy_states.spared) {
		draw_set_alpha(0.5);
	}
	
	var hurt = (instance_exists(obj_damage_bar) && obj_damage_bar.enemy == enemy);
	if (hurt || enemy.state == enemy_states.spared) {
		// The starting offset is not applied when Quigley is hit.
		// It would look weird if it was.
		bob_timer = 0.75;
		tail_timer = 0;
	} else {
		// Quigley moves a little faster than Anser.
		bob_timer += 0.015;
		if (bob_timer >= 1) {
			bob_timer -= 1;
		}
		
		tail_timer += 0.05;
		if (tail_timer == 1) {
			tail_timer = 0;
		}
	}
	
	draw_sprite_ext(spr_enemy_quigley_tail, 0, x - 24, y - 50, 1, 1, dsin(tail_timer * 360) * 5, c_white, enemy.state == enemy_states.spared ? 0.5 : 1);
	
	var bob_amount = dsin(bob_timer * 360);
	
	draw_sprite_ext(
		spr_enemy_quigley_arms_left,
		hurt ? 0 : (global.encounter.music_stopped ? 0 : (enemy.state == enemy_states.spared ? 1 : left_arm)),
		x + 18,
		y - 70 + bob_amount * 2,
		1,
		1,
		-3.55 + bob_amount * -3.55,
		c_white,
		enemy.state == enemy_states.spared ? 0.5 : 1
	);
	
	draw_sprite_ext(spr_enemy_quigley_body, 0, x, y, 45/44 + bob_amount * 1/44, 45/46 - bob_amount * 1/46, 0, c_white, enemy.state == enemy_states.spared ? 0.5 : 1);
	
	draw_sprite_ext(
		spr_enemy_quigley_arms_right,
		hurt ? 1 : (global.encounter.music_stopped ? 1 : (enemy.state == enemy_states.spared ? 2 : right_arm)),
		x - 16,
		y - 80 + bob_amount * 2,
		1,
		1,
		-2 + bob_amount * -2,
		c_white,
		enemy.state == enemy_states.spared ? 0.5 : 1
	);
	
	if (enemy.state == enemy_states.spared && global.encounter.enemies[1].state != enemy_states.dead) {
		// There's no need to apply the bob offset here, since this head can just always
		// be drawn at the correct - static - position.
		draw_sprite(spr_enemy_quigley_head_spared, 0, x + 16, y - 92);
	} else {
		draw_sprite(
			spr_enemy_quigley_heads,
			hurt ? 12 : (global.encounter.music_stopped ? 9 : (
				(enemy.state == enemy_states.spared && global.encounter.enemies[1].state == enemy_states.dead)
				? 10: head
			)),
			x + 16,
			y - 89 + bob_amount * 3
		);
	}
	
	draw_set_alpha(1);
}