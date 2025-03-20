center_y = y - 85;
damage_bar_y = y - 50;
vapor_sprite = spr_enemy_quigley_knocked_down;

head = 0;
left_arm = 0;
right_arm = 1;

// Offset randomly since it looks weird if Anser and Quigley's animations are perfectly in sync
bob_timer = 0.9;  // 0.25 is when the sprites are at their topmost position, which is where we want them to start.
tail_timer = 0.7;

// Revenge kill animation
revenge = false;
revenge_image = 0;