instance_create_layer(obj_battle_controller.box.x2 - 4, 300, "bullets", obj_bullet_quigley_trap, {image_angle: 90});
instance_create_layer(320, obj_battle_controller.box.y1 + 4, "bullets", obj_bullet_quigley_trap, {image_angle: 180});
instance_create_layer(obj_battle_controller.box.x1 + 4, 300, "bullets", obj_bullet_quigley_trap, {image_angle: 270});
instance_create_layer(320, obj_battle_controller.box.y2 - 4, "bullets", obj_bullet_quigley_trap);

dog = instance_create_layer(obj_battle_controller.box.x1 - 58, obj_battle_controller.box.y2 + 1, "bullets", obj_bullet_quigley_dog_jump, {above: true});
fox = instance_create_layer(obj_battle_controller.box.x2 + 63, obj_battle_controller.box.y2 + 1, "bullets", obj_bullet_anser_fox, {above: true});

stars_shot = 0;
alarm[0] = 8;

dog_triggered = false;