// Find all instances on the depth layer
// (This is being precalculated here to increase performance - it means dynamically created instances will not
// be automatically managed by the depth system, but that seems like a reasonable tradeoff.)
instances = ds_grid_create(2, 0);
instances_length = 0;

var elements = layer_get_all_elements(layer_get_name(layer));
for (var i = 0; i < array_length(elements); i++) {
	// There probably won't be any non-instances on the layer, but it feels correct to check
	if (layer_get_element_type(elements[i]) == layerelementtype_instance) {
		var instance = layer_instance_get_instance(elements[i]);
		
		if (instance != id) {
			ds_grid_resize(instances, 2, ++instances_length);
			ds_grid_set(instances, 0, instances_length - 1, instance);
		}
	}
}