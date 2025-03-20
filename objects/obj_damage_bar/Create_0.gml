text_y_offset = 0;
text_speed = -4;
text_stopped = false;

if (enemy.vulnerable > 0) {
	damage = floor(damage * 1.25);
}

target_health = max(0, enemy.current_health - damage);
shudder = 16;

show_bar = true;
if (enemy.state == enemy_states.knocked_down) {
	enemy.state = enemy_states.dead;
	show_bar = false;
	
	obj_battle_controller.earned_exp += enemy.execution_points;
	obj_battle_controller.earned_gold += enemy.gold;
}

alarm[0] = 1;

audio_play_sound(critical ? snd_damage_critical : snd_damage, 1, false);