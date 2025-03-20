image_index = irandom_range(0, 4);
image_speed = 0;
image_angle = irandom_range(0, 359);
image_blend = merge_color(choose(c_red, c_green, c_blue, c_yellow, c_orange, c_purple, c_fuchsia), c_white, 0.4);

// Start at a higher speed, then slow down
base_speed = random_range(4, 10);
speed = base_speed + 2;

direction = irandom_range(260, 280);
spin_speed = random_range(0.5, 2);
spin_dir = choose(-1, 1);