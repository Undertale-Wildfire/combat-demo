if (enemy.current_health > target_health) {
	enemy.current_health -= damage / 15;
	if (enemy.current_health <= target_health) {
		enemy.current_health = target_health;
		if (enemy.current_health == 0) {
			enemy.state = enemy_states.knocked_down;
		}
	}
}

enemy.instance.x += shudder;
if (shudder < 0) {
    shudder = -(shudder + 2);
} else {
    shudder = -shudder;
}

if (shudder == 0) {
	if (enemy.state == enemy_states.dead && enemy.default_kill) {
		// Some enemies (eg. Dummonstrous) play cutscenes before they die, so only vaporize the enemy here
		// if they're not supposed to do that.
		vaporize(enemy.instance.x, enemy.instance.y, enemy.instance.vapor_sprite);
		instance_destroy(enemy.instance);
	}
	
	alarm[1] = 15;
} else {
	alarm[0] = 2;
}