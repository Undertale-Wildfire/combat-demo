event_inherited();
enemy = 0;

pulsing = false;
pulse_progress = 0;

moving = false;
move_direction = -1;

// When there are more caltrops, shoot them faster.
caltrop_timer = irandom_range(caltrop_count == 9 ? 10 : 20, caltrop_count == 9 ? 20 : 40);
caltrops_shot = 0;

// Use an alternate sad sprite if Anser is dead
// (Unlike in obj_bullet_quigley_dog_jump, we don't need a custom_draw() function here, since this object only
// ever uses one sprite.)
if (global.encounter.enemies[1].state == enemy_states.dead) {
	sprite_index = spr_bullet_quigley_dog_sad;
}