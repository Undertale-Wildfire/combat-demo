event_inherited();
enemy = 0;

image_alpha = 0;
disappearing = false;

var base_speed = global.encounter.transformed ? 5 : 3;
speed_x = lengthdir_x(base_speed, dir);
speed_y = lengthdir_y(base_speed, dir);
moving = false;

inside_box = false;