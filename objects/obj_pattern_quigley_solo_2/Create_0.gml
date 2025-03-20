instance_create_layer(259, 385, "bullets", obj_bullet_quigley_trap);
instance_create_layer(320, 385, "bullets", obj_bullet_quigley_trap);
instance_create_layer(381, 385, "bullets", obj_bullet_quigley_trap);

instance_create_layer(412, 232, "bullets", obj_bullet_quigley_trap, {image_angle: 90});
instance_create_layer(412, 293, "bullets", obj_bullet_quigley_trap, {image_angle: 90});
instance_create_layer(412, 354, "bullets", obj_bullet_quigley_trap, {image_angle: 90});

instance_create_layer(259, 202, "bullets", obj_bullet_quigley_trap, {image_angle: 180});
instance_create_layer(320, 202, "bullets", obj_bullet_quigley_trap, {image_angle: 180});
instance_create_layer(381, 202, "bullets", obj_bullet_quigley_trap, {image_angle: 180});

instance_create_layer(229, 232, "bullets", obj_bullet_quigley_trap, {image_angle: 270});
instance_create_layer(229, 293, "bullets", obj_bullet_quigley_trap, {image_angle: 270});
instance_create_layer(229, 354, "bullets", obj_bullet_quigley_trap, {image_angle: 270});

var side = global.encounter.quigley_solo_2_side;
global.encounter.quigley_solo_2_side *= -1;

dog = instance_create_layer(
	side == -1 ? obj_battle_controller.box.x2 + 58 : obj_battle_controller.box.x1 - 58,
	obj_battle_controller.box.y2 + 1,
	"bullets",
	obj_bullet_quigley_dog_caltrops,
	{image_xscale: side, above: true, caltrop_count: 9}
);

alarm[0] = 150;