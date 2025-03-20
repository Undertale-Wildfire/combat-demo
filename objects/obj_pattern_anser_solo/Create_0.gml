var side = global.encounter.anser_solo_side;
global.encounter.anser_solo_side *= -1;

fox = instance_create_layer(
	side == -1 ? obj_battle_controller.box.x1 - 63 : obj_battle_controller.box.x2 + 63,
	obj_battle_controller.box.y2 + 1,
	"bullets",
	obj_bullet_anser_fox,
	{image_xscale: side, above: true}
);
fox.shooting = true;

stabs = 0;
alarm[0] = 30;