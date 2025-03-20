dog = instance_create_layer(obj_battle_controller.box.x1 - 58, obj_battle_controller.box.y2 + 1, "bullets", obj_bullet_quigley_dog_caltrops, {above: true});

traps = array_shuffle([
	{_x: 289, _y: obj_battle_controller.box.y2 - 4, side: directions.down},
	{_x: 350, _y: obj_battle_controller.box.y2 - 4, side: directions.down},
	{_x: 289, _y: obj_battle_controller.box.y1 + 4, side: directions.up},
	{_x: 350, _y: obj_battle_controller.box.y1 + 4, side: directions.up},
]);

alarm[0] = 15;