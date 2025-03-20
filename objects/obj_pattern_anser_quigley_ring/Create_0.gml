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

for (var dir = 0; dir < 360; dir += 45) {
	instance_create_layer(
		(obj_battle_controller.box.x1 + obj_battle_controller.box.x2) div 2,
		(obj_battle_controller.box.y1 + obj_battle_controller.box.y2) div 2,
		"bullets",
		obj_bullet_anser_star,
		{above: true, move_type: star_move_types.circle, move_direction: dir, circle_radius: 160}
	);
}

alarm[0] = 150;