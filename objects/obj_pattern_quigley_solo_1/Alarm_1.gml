if (array_length(traps) > 0) {
	var trap = array_shift(traps);
	instance_create_layer(trap._x, trap._y, "top", obj_quigley_warning_box, {side: trap.side});
	alarm[1] = 40;
} else {
	// Replace the dog bullet with the jumping one
	instance_destroy(dog);
	dog = instance_create_layer(obj_battle_controller.box.x1 - 58, obj_battle_controller.box.y2 + 1, "bullets", obj_bullet_quigley_dog_jump, {above: true});
	
	dog.pulsing = true;
	instance_create_layer(obj_soul.x, obj_soul.y, "top", obj_quigley_reticle);
	audio_play_sound(snd_dog_angry, 1, false);
}