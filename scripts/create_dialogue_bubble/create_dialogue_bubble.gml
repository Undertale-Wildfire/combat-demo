function create_dialogue_bubble(tail_x, tail_y, _tail_side, _width, _height, _pages) {
	return instance_create_layer(tail_x, tail_y, "system", obj_dialogue_bubble, {
		tail_side: _tail_side,
		width: _width,
		height: _height,
		pages: _pages
	});
}