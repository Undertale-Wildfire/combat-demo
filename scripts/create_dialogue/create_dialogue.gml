// Creates a dialogue box.
function create_dialogue(_side, _pages) {
	return instance_create_layer(0, 0, "system", obj_dialogue_box, {side: _side, pages: _pages});
}