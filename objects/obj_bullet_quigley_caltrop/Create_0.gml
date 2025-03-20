event_inherited();
dangerous = false;
enemy = 0;

image_speed = 0;
image_alpha = 0;
image_blend = c_gray;

moving = false;
decelerating = false;
activating = false;

// Start moving toward box
box = obj_battle_controller.box;
speed_x = 4 * sign((box.x1 + box.x2) / 2 - x);
speed_y = 4 * sign((box.y1 + box.y2) / 2 - y);
inside_box = false;

alarm[1] = irandom_range(60, 120);