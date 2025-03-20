if (side == directions.left) {
	instance_create_layer(obj_battle_controller.box.x1 - 29, y, "bullets", obj_bullet_anser_slash);
} else {
	instance_create_layer(obj_battle_controller.box.x2 + 29, y, "bullets", obj_bullet_anser_slash, {image_xscale: -1});
}

instance_destroy();