if (stabs == 3 && !instance_exists(obj_bullet_anser_stab)) {
	// Stops this from running again.
	// Not the cleanest, but prevents having to add another flag.
	stabs = 0;
	alarm[2] = 5;
}