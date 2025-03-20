function trigger() {
	obj_player.x = 260;
	instance_create_layer(x, y, "system", obj_anser_quigley_cutscene);	
	instance_destroy();
}