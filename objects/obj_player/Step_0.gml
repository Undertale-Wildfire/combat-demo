// Calculate directions to move in
var dir_x;
var dir_y;

if (can_player_move()) {
	dir_x = global.keys.right_held - global.keys.left_held; 
	dir_y = global.keys.down_held - global.keys.up_held;
} else {
	dir_x = 0;
	dir_y = 0;
}

// Move player and handle collisions
var move_speed = global.keys.cancel_held ? 5 : 3;
	
x += dir_x * move_speed;
if (place_meeting(x, y, obj_wall)) {
	x = xprevious;
	while (!place_meeting(x, y, obj_wall)) {
		x += dir_x;
	}
	x -= dir_x;
	
	// Handle X slopes (only if not moving diagonally)
	if (dir_y == 0) {
		repeat (move_speed - abs(x - xprevious)) {
			if (place_meeting(x + dir_x, y, obj_wall)) {
				if (!place_meeting(x + dir_x, y - 1, obj_wall)) {
					x += dir_x;
					y -= 1;
				} else if (!place_meeting(x + dir_x, y + 1, obj_wall)) {
					x += dir_x;
					y += 1;
				}
			} else {
				x += dir_x;
			}
		}
	}
}
	
y += dir_y * move_speed;
if (place_meeting(x, y, obj_wall)) {
	y = yprevious;
	while (!place_meeting(x, y, obj_wall)) {
		y += dir_y;
	}
	y -= dir_y;
	
	// Handle Y slopes (only if not moving diagonally)
	if (dir_x == 0) {
		repeat (move_speed - abs(y - yprevious)) {
			if (place_meeting(x, y + dir_y, obj_wall)) {
				if (!place_meeting(x - 1, y + dir_y, obj_wall)) {
					x -= 1;
					y += dir_y;
				} else if (!place_meeting(x + 1, y + dir_y, obj_wall)) {
					x += 1;
					y += dir_y;
				}
			} else {
				y += dir_y;
			}
		}
	}
}

// Handle direction switches
if (dir_x == 0) {
	if (dir_y == -1) {
		facing = directions.up;
	} else if (dir_y == 1) {
		facing = directions.down;
	}
} else if (dir_y == 0) {
	if (dir_x == -1) {
		facing = directions.left;
	} else if (dir_x == 1) {
		facing = directions.right;
	}
} else {
	switch (facing) {
		case directions.left:
			if (dir_x == 1) facing = directions.right;
			break;
		
		case directions.right:
			if (dir_x == -1) facing = directions.left;
			break;
		
		case directions.up:
			if (dir_y == 1) facing = directions.down;
			break;
		
		case directions.down:
			if (dir_y == -1) facing = directions.up;
			break;
	}
}

// Set correct sprite
var old_sprite = sprite_index;

var old_moving = moving;
moving = (x != xprevious || y != yprevious);
var running = (moving && global.keys.cancel_held);

switch (facing) {
	case directions.right: sprite_index = spr_riley_right; break;
	case directions.up: sprite_index = spr_riley_up; break;
	case directions.left: sprite_index = spr_riley_left; break;
	case directions.down: sprite_index = spr_riley_down; break;
}

if (moving != old_moving) {
	if (moving) {
		// Start on the second frame so the animation feels responsive
		image_index = 1;
	} else {
		// The idle frame is the first frame of the walk animation.
		image_index = 0;
		image_speed = 0;
	}
}

if (moving) {
	image_speed = (running ? 5 / 3 : 1);
}

// Open menu (if you can't move you shouldn't be able to do this either)
if (global.keys.menu_pressed && can_player_move()) {
	instance_create_layer(0, 0, "system", obj_player_menu);	
}

// Interact with objects
// (obj_interact_box represents an interactable zone.)
if (!can_interact) {
	if (can_player_move() && global.keys.confirm_pressed) {
		var check_x1;
		var check_y1;
		var check_x2;
		var check_y2;
		
		switch (facing) {
			case directions.right:
				check_x1 = bbox_right + 1;
				check_y1 = (bbox_top + bbox_bottom) / 2;
				check_x2 = check_x1 + 14;
				check_y2 = check_y1;
				break;
			
			case directions.up:
				check_x1 = x;
				check_y1 = bbox_top - 1;
				check_x2 = check_x1;
				check_y2 = check_y1 - 14;
				break;
			
			case directions.left:
				check_x1 = bbox_left - 1;
				check_y1 = (bbox_top + bbox_bottom) / 2;
				check_x2 = check_x1 - 14;
				check_y2 = check_y1;
				break;
			
			case directions.down:
				check_x1 = x;
				check_y1 = bbox_bottom + 1;
				check_x2 = check_x1;
				check_y2 = check_y1 + 14;
				break;
		}
		
		var instance = collision_line(check_x1, check_y1, check_x2, check_y2, obj_interact_box, false, false);
		if (instance != noone) {
			if (variable_instance_exists(instance, "require_facing")) {
				if (instance.require_facing == facing) {
					instance.interact();	
				}
			} else {
				instance.interact();
			}
		}
	}
} else {
	can_interact = false;	
}

if (!can_player_move()) {
	can_interact = true;	
}

// Handle triggers
with (obj_trigger) {
	if (place_meeting(x, y, obj_player)) {
		if (!touching_player) {
			trigger();
			touching_player = true;
		}
	} else {
		touching_player = false;
	}
}

// Update queue for followers
if (moving) {
	array_push(follow_queue, {_x: x, _y: y, facing: facing});
	array_delete(follow_queue, 0, 1);
}