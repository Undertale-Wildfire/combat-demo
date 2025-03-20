instance_create_layer(
	clamp(obj_soul.x, obj_battle_controller.box.x1 + 20, obj_battle_controller.box.x2 - 20),
	0,
	"top",
	obj_anser_warning_line
);

if (++stabs < 3) {
	alarm[1] = 45;
}