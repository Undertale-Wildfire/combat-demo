if (++reticles_spawned <= 3) {
	instance_create_layer(obj_soul.x, obj_soul.y, "top", obj_quigley_reticle);
	alarm[0] = (reticles_spawned == 3 ? 135 : 90);
} else {
	instance_destroy();
}