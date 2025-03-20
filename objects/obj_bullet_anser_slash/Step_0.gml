x += 15 * image_xscale;

// Destroy once no longer in the box
if (bbox_left > obj_battle_controller.box.x2 - 5 || bbox_right < obj_battle_controller.box.x1 + 5) {
	instance_destroy();
}