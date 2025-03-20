dog = instance_create_layer(obj_battle_controller.box.x1 - 58, obj_battle_controller.box.y2 + 1, "bullets", obj_bullet_quigley_dog_caltrops, {above: true});
instance_create_layer(obj_battle_controller.box.x2 + 63, obj_battle_controller.box.y2 + 1, "bullets", obj_bullet_anser_fox, {above: true});

stabs = 0;
alarm[0] = 15;