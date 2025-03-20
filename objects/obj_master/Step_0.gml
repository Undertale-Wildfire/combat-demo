if (keyboard_check(vk_escape)) {
	if (++quit_timer == 30) {
		game_end();	
	}
} else if (quit_timer > 0) {
	quit_timer = 0;	
}