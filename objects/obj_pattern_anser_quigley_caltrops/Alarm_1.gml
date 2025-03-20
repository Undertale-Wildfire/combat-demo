instance_create_layer(
	0,
	clamp(obj_soul.y, obj_battle_controller.box.y1 + 39, obj_battle_controller.box.y2 - 38),
	"top",
	obj_anser_warning_box,
	{side: choose(directions.left, directions.right)}
);

alarm[2] = 45;