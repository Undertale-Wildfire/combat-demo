// Sort instances by Y position
// (this is in the End Step event to make sure we're working with the final Y positions of the instances)
for (var i = 0; i < instances_length; i++) {
	var instance = instances[# 0, i];
	
	// If the instance no longer exists, remove its row from the grid
	if (!instance_exists(instance)) {
		ds_grid_set_grid_region(instances, instances, 0, i + 1, 1, --instances_length, 0, i);
		ds_grid_resize(instances, 2, instances_length);
		
		i--;
		continue;
	}
	
	if (variable_instance_exists(instance, "on_top_of")) {
		// Always draw above the other instance
		// TODO: Should probably improve this, this is a hack. It works as long as other instances stick to
		//       integer positions.
		ds_grid_set(instances, 1, i, instance.on_top_of.y + 1 - (instance.on_top_of.y - instance.y) / instance.on_top_of.sprite_height);
	} else {
		ds_grid_set(instances, 1, i, instance.y);
	}
}

ds_grid_sort(instances, 0, true);
ds_grid_sort(instances, 1, true);