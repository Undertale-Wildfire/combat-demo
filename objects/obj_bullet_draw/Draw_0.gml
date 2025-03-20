if (!surface_exists(below_surface)) {
	below_surface = surface_create(640, 480);
}

surface_set_target(below_surface);
draw_clear_alpha(c_black, 0);

with (obj_bullet) {
	if (!above) {
		if (variable_instance_exists(id, "custom_draw")) {
			custom_draw();
		} else {
			draw_self();
		}
	}
}

surface_reset_target();
draw_surface_part(
	below_surface,
	obj_battle_controller.box.x1 + 5,
	obj_battle_controller.box.y1 + 5,
	obj_battle_controller.box.x2 - obj_battle_controller.box.x1 - 4,
	obj_battle_controller.box.y2 - obj_battle_controller.box.y1 - 4,
	obj_battle_controller.box.x1 + 5,
	obj_battle_controller.box.y1 + 5
);

if (!surface_exists(above_surface)) {
	above_surface = surface_create(640, 480);
}

surface_set_target(above_surface);
draw_clear_alpha(c_black, 0);

with (obj_bullet) {
	if (above) {
		if (variable_instance_exists(id, "custom_draw")) {
			custom_draw();
		} else {
			draw_self();
		}
	}
}

surface_reset_target();

if (!surface_exists(outline_surface)) {
	outline_surface = surface_create(640, 480);
}

surface_copy(outline_surface, 0, 0, above_surface);
surface_set_target(outline_surface);
gpu_set_blendmode(bm_subtract);
draw_rectangle(obj_battle_controller.box.x1 + 5, obj_battle_controller.box.y1 + 5, obj_battle_controller.box.x2 - 5, obj_battle_controller.box.y2 - 5, false);
gpu_set_blendmode(bm_normal);
surface_reset_target();

shader_set(sh_outline_bullet);
var texture = surface_get_texture(outline_surface);
shader_set_uniform_f(pixel_width, texture_get_texel_width(texture));
shader_set_uniform_f(pixel_height, texture_get_texel_height(texture));
draw_surface(outline_surface, 0, 0);
shader_reset();

draw_surface(above_surface, 0, 0);