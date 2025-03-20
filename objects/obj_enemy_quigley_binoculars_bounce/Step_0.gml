x -= 2;
y += speed_y++;

if (y >= 245 && !bounced) {
	y = 245;
	speed_y = -10;
	bounced = true;
	
	audio_play_sound(snd_bullet_bounce, 1, false);
}

// The top pixel of the sprite is black, so it's fine if it's on-screen when the binoculars are destroyed.
if (bbox_top >= 479) {
	instance_destroy();
}