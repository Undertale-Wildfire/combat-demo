// Draw instances in order
for (var i = 0; i < instances_length; i++) {
	var instance = instances[# 0, i];
	if (variable_instance_exists(instance, "custom_draw")) {
		instance.custom_draw();
	} else {
		with (instance) {
			draw_self();
		}
	}
}