var trap_y = obj_battle_controller.box.y2 - 4;

instance_create_layer(259, trap_y, "bullets", obj_bullet_quigley_trap);
instance_create_layer(381, trap_y, "bullets", obj_bullet_quigley_trap);

instance_create_layer(259, trap_y - 29, "bullets", obj_bullet_quigley_cheese);
instance_create_layer(381, trap_y - 29, "bullets", obj_bullet_quigley_cheese);

alarm[0] = 150;