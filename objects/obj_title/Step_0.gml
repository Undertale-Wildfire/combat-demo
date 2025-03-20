if (moving) {
	progress += 0.04;
	y = 240 - (1 - power(1 - progress, 3)) * 46;
	
	if (progress == 1) {
		moving = false;
		progress = 0;
		alarm[2] = 6;
	}
} else if (growing) {
	progress += 0.025;
	image_xscale = 2 + dsin(progress * 180) * 0.3;
	image_yscale = image_xscale;
	
	if (progress == 1) {
		growing = false;
		echoing = true;
		
		y = 240;
		sprite_index = spr_title_wildfire;
		image_blend = c_white;
		orange_alpha = 1;
		
		alarm[3] = 100;
	} else {
		image_blend = merge_color(c_white, #ff8100, progress);
	}
} else if (sliding_up) {
	y -= (global.keys.confirm_held && room == rm_credits ? 8 : 2);
} else if (challenge_complete) {
	if (progress < 1) {
		progress += 0.04;
		y = 240 - (1 - power(1 - progress, 3)) * 20;
	} else {
		challenge_typewriter.step();
		if (global.keys.confirm_pressed && challenge_typewriter.shown_chars == challenge_typewriter.text_length) {
			challenge_complete = false;
			fading = true;
		}
	}
} else if (fading) {
	image_alpha -= 0.05;
	if (image_alpha == 0) {
		fading = false;
		alarm[4] = 60;
	}
}

if (echoing) {
	echo_timer++;
	if (echo_timer == 16) {
		echoing = false;
	}
}

if (global.keys.confirm_pressed && image_alpha == 1 && global.combat_demo_flags.completed_tutorial && room != rm_credits) {
	room_goto(rm_menu);
}