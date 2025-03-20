// Registers an instance with the depth system in the current room.
function depth_add_instance(instance) {
	ds_grid_resize(obj_depth.instances, 2, ++obj_depth.instances_length);
	ds_grid_set(obj_depth.instances, 0, obj_depth.instances_length - 1, instance);
}