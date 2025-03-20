audio_stop_all();

soul_sprite = spr_soul;
bright_soul_alpha = 1;
alarm[0] = 20;

// Distance the SOUL has to travel to reach the middle of the screen
soul_distance_x = 320 - global.death_x;
soul_distance_y = 270 - global.death_y;

soul_moving = false;
soul_move_progress = 0;

game_over_fading = false;
game_over_alpha = 0;

music = undefined;
music_beat_length = time_bpm_to_seconds(85);
music_color_shift_timer = 0;
music_color_shift_cycle_length = music_beat_length * 120;
music_buildup_start = music_beat_length * 28;
music_building_up = false;
music_drop = music_beat_length * 32;

pulsing = false;
time_source = undefined;

dialogue_running = false;
dialogue_page = 0;

ui_fading = false;
ui_alpha = 0;

selection = 0;

refusing = false;
refuse_timer = 0;
quitting = false;

overlay_alpha = 0;